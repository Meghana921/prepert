DROP PROCEDURE IF EXISTS update_eligibility_template;
DELIMITER $$
CREATE PROCEDURE update_eligibility_template(
  IN template_id BIGINT,
  IN template_name VARCHAR(100),
  IN eligibility_questions JSON
)
BEGIN
  
  DECLARE template_exists INT DEFAULT 0;
  DECLARE custom_error VARCHAR(255);
  DECLARE duplicate_count INT DEFAULT 0;
  
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error ,"An error occurred while inserting template") AS message;
  END;

  START TRANSACTION;
  IF exists( SELECT 1 FROM dt_eligibility_templates WHERE TID = template_id)THEN
	UPDATE dt_eligibility_templates
    SET name = template_name
    WHERE TID = template_id;
  ELSE
	SET custom_error = "Template not found!";
    SIGNAL SQLSTATE "45000";
  END IF;
    DELETE FROM dt_eligibility_questions
    WHERE template_tid = template_id;
    
    -- Insert new questions
 INSERT INTO dt_eligibility_questions(template_tid, question, deciding_answer, sequence_number) 
  SELECT 
    template_id,
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
    WHERE template_tid = template_id
    GROUP BY question
    HAVING cnt > 1
  ) AS duplicates;

  IF duplicate_count > 0 THEN 
    SET custom_error = 'Duplicate questions found in the template';
    SIGNAL SQLSTATE '45000';
  END IF;
  SELECT JSON_OBJECT(
   "template_id" , template_id,
    "template_name" , template_name) as data;
COMMIT;
END $$

DELIMITER ;

CALL update_eligibility_template(
  1,  -- creator_id (engineering manager's ID)
  'Data Engineer  2025',  -- template_name
  -- JSON array of questions (engineering-focused)
  '[
    {
      "question": "Do you have 3+ years of professional software development experience?",
      "deciding_answer": "yes",
      "sequence_number": 1
    },
    {
      "question": "Are you proficient in Python or Java?",
      "deciding_answer": "yes",
      "sequence_number": 2
    },
    {
      "question": "Have you worked with cloud platforms (AWS/Azure/GCP)?",
      "deciding_answer": "yes",
      "sequence_number": 3
    },
    {
      "question": "Can you demonstrate experience with CI/CD pipelines?",
      "deciding_answer": "no",
      "sequence_number": 4
    }
  ]'
);

