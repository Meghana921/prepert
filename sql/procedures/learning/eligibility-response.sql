DROP PROCEDURE IF EXISTS eligibility_response;
DELIMITER $$

CREATE PROCEDURE eligibility_response(
  IN in_user_id BIGINT,
  IN in_program_id BIGINT,
  IN in_questions JSON
)
BEGIN
  DECLARE template_id BIGINT UNSIGNED;
  DECLARE total_questions INT DEFAULT 0;
  DECLARE correct_answers INT DEFAULT 0;
  DECLARE is_eligible BOOLEAN DEFAULT FALSE;
  DECLARE in_regret_message TEXT;
  DECLARE response_count INT DEFAULT 0;
  DECLARE expected_questions INT DEFAULT 0;
  DECLARE custom_error VARCHAR(255);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error, 'An error occurred while processing your eligibility response') AS data;
  END;

  START TRANSACTION;

  -- 1. Get eligibility template and regret message
  SELECT eligibility_template_tid, regret_message 
  INTO template_id, in_regret_message
  FROM dt_learning_programs 
  WHERE tid = in_program_id;

  IF template_id IS NULL THEN
    SET custom_error = "Program not found!";
    SIGNAL SQLSTATE '45000';
  END IF;

  -- 2. Prevent resubmission
  IF EXISTS (
    SELECT 1 FROM dt_eligibility_responses 
    WHERE user_tid = in_user_id AND learning_program_tid = in_program_id
  ) THEN
    SET custom_error = 'You have already submitted an eligibility response for this program';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- 3. Count expected questions
  SELECT COUNT(tid) INTO expected_questions
  FROM dt_eligibility_questions
  WHERE template_tid = template_id;

  -- 4. Insert responses
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
      response ENUM('yes','no') PATH '$.response',
      question_id FOR ORDINALITY
    )
  ) AS q
  WHERE q.question_tid IN (
    SELECT tid FROM dt_eligibility_questions 
    WHERE template_tid = template_id
  );

  -- 5. Validate response count
  SELECT ROW_COUNT() INTO response_count;

  IF response_count = 0 THEN
    SET custom_error = 'No valid responses were inserted';
    SIGNAL SQLSTATE '45000';
  ELSEIF response_count != expected_questions THEN
    SET custom_error = CONCAT('Incomplete responses. Expected: ', expected_questions, ', Received: ', response_count);
    SIGNAL SQLSTATE '45000';
  END IF;

  -- 6. Evaluate eligibility
  SELECT COUNT(r.tid) INTO correct_answers
  FROM dt_eligibility_responses r
  JOIN dt_eligibility_questions q ON r.question_tid = q.tid
  WHERE r.user_tid = in_user_id
    AND r.learning_program_tid = in_program_id
    AND r.answer = q.deciding_answer;

  SET is_eligible = (correct_answers = expected_questions);

  -- 7. Record result
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

  -- 8. Return final JSON response
  SELECT JSON_OBJECT(
    'status', TRUE,
    'data', JSON_OBJECT(
      'user_id', in_user_id,
      'program_id', in_program_id,
      'passed', is_eligible,
      'message', CASE 
                  WHEN is_eligible THEN 'You are eligible for this program'
                  ELSE in_regret_message
                END
    )
  ) AS data;

  COMMIT;
END $$

DELIMITER ;
