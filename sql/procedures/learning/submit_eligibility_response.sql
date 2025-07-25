DROP PROCEDURE IF EXISTS eligibility_response;
DELIMITER $$

CREATE PROCEDURE eligibility_response(
  IN in_user_id BIGINT,
  IN in_program_id BIGINT,
  IN in_questions JSON
)
/* Processes user responses to determine program eligibility */
BEGIN
  DECLARE template_id BIGINT UNSIGNED;
  DECLARE total_questions INT DEFAULT 0;
  DECLARE correct_answers INT DEFAULT 0;
  DECLARE is_eligible BOOLEAN DEFAULT FALSE;
  DECLARE in_regret_message TEXT;
  DECLARE response_count INT DEFAULT 0;
  DECLARE expected_questions INT DEFAULT 0;
  DECLARE custom_error VARCHAR(255);
  DECLARE error_message VARCHAR(255);
  DECLARE  sponsred_slots_available BOOLEAN DEFAULT false;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 error_message= MESSAGE_TEXT;
    ROLLBACK;
    SET custom_error = COALESCE(custom_error,error_message);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END;

  START TRANSACTION;

  -- Get program's eligibility template
  SELECT eligibility_template_tid, regret_message 
  INTO template_id, in_regret_message
  FROM dt_learning_programs 
  WHERE tid = in_program_id;

  IF template_id IS NULL THEN
    SET custom_error = "Program not found!";
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=custom_error;
  END IF;

  -- Prevent duplicate responses
  IF EXISTS (
    SELECT 1 FROM dt_eligibility_responses 
    WHERE user_tid = in_user_id AND learning_program_tid = in_program_id
  ) THEN
    SET custom_error = 'You have already submitted an eligibility response for this program';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
  END IF;

  -- Count required questions
  SELECT COUNT(tid) INTO expected_questions
  FROM dt_eligibility_questions
  WHERE template_tid = template_id;

  -- Store user responses
  INSERT INTO dt_eligibility_responses (
    user_tid, 
    learning_program_tid,
    question_tid,
    answer
  ) 
  SELECT 
    in_user_id,
    in_program_id,
    q.question_tid,
    q.response
  FROM JSON_TABLE(
    in_questions,
    '$[*]' COLUMNS (
      question_tid BIGINT PATH '$.question_tid',
      response ENUM('0','1') PATH '$.response',
      question_id FOR ORDINALITY
    )
  ) AS q
  WHERE q.question_tid IN (
    SELECT tid FROM dt_eligibility_questions 
    WHERE template_tid = template_id
  );

  -- Validate response count
  SELECT ROW_COUNT() INTO response_count;

  IF response_count = 0 THEN
    SET custom_error = 'No valid responses were inserted';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
  ELSEIF response_count != expected_questions THEN
    SET custom_error = CONCAT('Incomplete responses. Expected: ', expected_questions, ', Received: ', response_count);
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
  END IF;

  -- Calculate correct answers
  SELECT COUNT(r.tid) INTO correct_answers
  FROM dt_eligibility_responses r
  JOIN dt_eligibility_questions q ON r.question_tid = q.tid
  WHERE r.user_tid = in_user_id
    AND r.learning_program_tid = in_program_id
    AND r.answer = q.deciding_answer;

  SET is_eligible = (correct_answers = expected_questions);

  -- Record final eligibility result
  INSERT INTO dt_eligibility_results (
    user_tid,
    learning_program_tid,
    passed
  ) VALUES (
    in_user_id,
    in_program_id,
    is_eligible
  )
  ON DUPLICATE KEY UPDATE 
    passed = is_eligible;

-- CHECK IF sponsered_slots available
  IF EXISTS (SELECT 1
  FROM dt_program_sponsorships
  WHERE learning_program_tid = in_program_id AND seats_used < seats_allocated AND is_cancelled = false
  LIMIT 1) THEN
  SET sponsred_slots_available = TRUE;
  END IF;
  
  -- Return eligibility decision
  SELECT JSON_OBJECT(
      'user_id', in_user_id,
      'program_id', in_program_id,
      'passed', is_eligible,
      'message', CASE 
                  WHEN is_eligible THEN 'You are eligible for this program'
                  ELSE in_regret_message
                END,
	'sponsred_slots_available', sponsred_slots_available
  ) AS data;

  COMMIT;
END $$

DELIMITER ;