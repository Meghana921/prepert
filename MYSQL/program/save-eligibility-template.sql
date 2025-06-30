DROP PROCEDURE IF EXISTS save_eligibility_template;

DELIMITER $$
CREATE PROCEDURE save_eligibility_template(
  IN creator_id BIGINT,
  IN template_name VARCHAR(100),
  IN eligibility_questions JSON
)
BEGIN
  DECLARE custom_error VARCHAR(255);
  DECLARE eligibility_template_tid BIGINT;
  DECLARE existing_tid BIGINT;
  DECLARE duplicate_count INT DEFAULT 0;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    IF custom_error IS NOT NULL THEN 
      SELECT custom_error AS error;
    ELSE
      SELECT "An error occurred while inserting template" AS message;
    END IF;
  END;

  START TRANSACTION;
  
  -- Check if template already exists
  SELECT TID INTO existing_tid FROM dt_eligibility_templates
  WHERE creator_tid = creator_id AND name = template_name;

  IF existing_tid IS NOT NULL THEN 
    SET custom_error = CONCAT(template_name, " template already exists. You can view and edit template.");
    SIGNAL SQLSTATE "45000";
  ELSE
    -- Insert new template
    INSERT INTO dt_eligibility_templates(creator_tid, name) 
    VALUES (creator_id, template_name);
    SET eligibility_template_tid = LAST_INSERT_ID();
  END IF;

  -- Insert questions using JSON_TABLE
  INSERT INTO dt_eligibility_questions(template_tid, question, deciding_answer, sequence_number) 
  SELECT 
    eligibility_template_tid,
    q.question,
    q.deciding_answer,
    q.sequence_number
  FROM JSON_TABLE(
    eligibility_questions,
    '$[*]' COLUMNS(
      question TEXT PATH '$.question',
      deciding_answer ENUM("yes","no") PATH '$.deciding_answer',
      sequence_number INT PATH '$.sequence_number',
      question_id FOR ORDINALITY
    )
  ) AS q
  WHERE q.question IS NOT NULL;

  -- Check for duplicate questions
  SELECT COUNT(*) INTO duplicate_count
  FROM (
    SELECT question, COUNT(*) AS cnt
    FROM dt_eligibility_questions
    WHERE template_tid = eligibility_template_tid
    GROUP BY question
    HAVING cnt > 1
  ) AS duplicates;

  IF duplicate_count > 0 THEN 
    SET custom_error = 'Duplicate questions found in the template';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Return the created template
  SELECT 
    eligibility_template_tid AS template_id,
    template_name AS template_name;
  
  COMMIT;
END $$
DELIMITER ;