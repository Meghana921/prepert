DROP PROCEDURE IF EXISTS update_eligibility_template;
DELIMITER $$

CREATE PROCEDURE update_eligibility_template(
  IN in_template_id BIGINT,
  IN in_template_name VARCHAR(100),
  IN in_eligibility_questions JSON
)
BEGIN
  DECLARE template_exists INT DEFAULT 0;
  DECLARE custom_error VARCHAR(255) DEFAULT NULL;
  DECLARE duplicate_count INT DEFAULT 0;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT  COALESCE(custom_error, 'An error occurred while updating the template') as message;
  END;

  START TRANSACTION;

  -- Check template existence
  SELECT COUNT(*) INTO template_exists
  FROM dt_eligibility_templates
  WHERE tid = in_template_id;

  IF template_exists = 0 THEN
    SET custom_error = 'Template not found!';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Update template name
  UPDATE dt_eligibility_templates
  SET name = in_template_name
  WHERE tid = in_template_id;

  -- Delete old questions
  DELETE FROM dt_eligibility_questions
  WHERE template_tid = in_template_id;

  -- Insert new questions
  INSERT INTO dt_eligibility_questions(template_tid, question, deciding_answer, sequence_number)
  SELECT 
    in_template_id,
    q.question,
    q.deciding_answer,
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
  SELECT COUNT(*) INTO duplicate_count
  FROM (
    SELECT question, COUNT(*) AS cnt
    FROM dt_eligibility_questions
    WHERE template_tid = in_template_id
    GROUP BY question
    HAVING cnt > 1
  ) AS duplicates;

  IF duplicate_count > 0 THEN
    SET custom_error = 'Duplicate questions found in the template';
    SIGNAL SQLSTATE '45000';
  END IF;

  COMMIT;

  -- Return success response
  SELECT JSON_OBJECT(
      'template_id', in_template_id,
      'template_name', in_template_name
  ) AS data;

END $$

DELIMITER ;


