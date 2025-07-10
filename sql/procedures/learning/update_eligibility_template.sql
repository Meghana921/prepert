DROP PROCEDURE IF EXISTS update_eligibility_template;
DELIMITER $$

/* Updates an existing eligibility template including its questions */
CREATE PROCEDURE update_eligibility_template(
  IN in_template_id BIGINT,
  IN in_template_name VARCHAR(100),
  IN in_eligibility_questions JSON
)
BEGIN
  DECLARE template_exists INT DEFAULT 0;
  DECLARE custom_error VARCHAR(255) DEFAULT NULL;
  DECLARE duplicate_count INT DEFAULT 0;

  DECLARE error_message VARCHAR(255);
    -- Error handler for rollback and exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
    error_message= MESSAGE_TEXT;
    ROLLBACK;
    SET custom_error = COALESCE(custom_error,error_message);
    SIGNAL SQLSTATE '45000'
    
        SET MESSAGE_TEXT = custom_error;
END;

  START TRANSACTION;

  -- Check template existence
  IF NOT EXISTS (SELECT 1
  FROM dt_eligibility_templates
  WHERE tid = in_template_id) THEN
    SET custom_error = 'Template not found!' ;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Update template name
  UPDATE dt_eligibility_templates
  SET name = in_template_name
  WHERE tid = in_template_id;

-- Checking if templete is renamed as existing template
  IF EXISTS (SELECT count(tid) as cnt from dt_eligibility_templates
  WHERE name = in_template_name
  GROUP BY creator_tid
  having cnt > 1) THEN
  SET custom_error = "Please choose a different name — this template already exists";
  SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
  END IF;
  COMMIT;

  -- Delete old questions
  DELETE FROM dt_eligibility_questions
  WHERE template_tid = in_template_id;

  -- Insert new questions
  INSERT INTO dt_eligibility_questions(template_tid, question, deciding_answer, sequence_number)
  SELECT 
    in_template_id,
    q.question,
    CASE WHEN q.deciding_answer = "yes" THEN "1" ELSE "0" END,
    q.sequence_number
  FROM JSON_TABLE(
    in_eligibility_questions,
    '$[*]' COLUMNS(
      question TEXT PATH '$.question',
      deciding_answer ENUM('yes','no') PATH '$.deciding_answer',
      sequence_number INT PATH '$.sequence_number',
      question_id FOR ORDINALITY
    )
  ) AS q
  WHERE q.question IS NOT NULL;

  -- Check for duplicates
 IF EXISTS(
    SELECT  COUNT(tid) AS cnt
    FROM dt_eligibility_questions
    WHERE template_tid = in_template_id
    GROUP BY question
    HAVING cnt > 1
  ) THEN
    SET custom_error = 'Duplicate questions found in the template';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;


  -- Return success response
  SELECT JSON_OBJECT(
      'template_id', in_template_id,
      'template_name', in_template_name
  ) AS data;

END $$

DELIMITER ;