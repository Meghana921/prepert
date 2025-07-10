DROP PROCEDURE IF EXISTS add_eligibility_template;

DELIMITER //
CREATE PROCEDURE add_eligibility_template (
    IN in_creator_id BIGINT,
    IN in_template_name VARCHAR(100),
    IN in_eligibility_questions JSON
)
 BEGIN
-- Variable declarations
DECLARE custom_error VARCHAR(255) DEFAULT NULL;
DECLARE eligibility_template_tid BIGINT;
DECLARE error_message VARCHAR(255);

-- Error handler: rollback and raise error with custom or default message
DECLARE EXIT HANDLER FOR SQLEXCEPTION 
BEGIN 
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
SET
    custom_error = COALESCE(custom_error, error_message);
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
END;

-- Start transaction
START TRANSACTION;

-- Check if a template with the same name already exists for the same creator
IF EXISTS (
    SELECT
        1
    FROM
        dt_eligibility_templates
    WHERE
        creator_tid = in_creator_id
        AND name = in_template_name
) THEN
SET
    custom_error = 'An entry with the given template name already exists. Please use a different name or update the existing one.';

SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = custom_error;

END IF;

-- Insert template
INSERT INTO
    dt_eligibility_templates (creator_tid, name)
VALUES
    (in_creator_id, in_template_name);

SET
    eligibility_template_tid = LAST_INSERT_ID ();

-- Insert questions from JSON
INSERT INTO
    dt_eligibility_questions (
        template_tid,
        question,
        deciding_answer,
        sequence_number
    )
SELECT
    eligibility_template_tid,
    q.question,
   CASE WHEN q.deciding_answer = "yes" THEN "1" ELSE "0" END,
    q.sequence_number
FROM
    JSON_TABLE (
        in_eligibility_questions,
        '$[*]' COLUMNS (
            question TEXT PATH '$.question',
            deciding_answer ENUM ("yes", "no") PATH '$.deciding_answer',
            sequence_number INT PATH '$.sequence_number'
        )
    ) AS q
WHERE
    q.question IS NOT NULL;

-- Check for duplicate questions in same template
IF EXISTS (
    SELECT
        COUNT(question) as cnt
    FROM
        dt_eligibility_questions
    WHERE
        template_tid = eligibility_template_tid
    GROUP BY
        question
    HAVING
        cnt > 1
) THEN
SET
    custom_error = 'Duplicate questions found in the template';

SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = custom_error;

END IF;

COMMIT;

-- Return response
SELECT
    JSON_OBJECT (
        'template_id',
        eligibility_template_tid,
        'template_name',
        in_template_name
    ) AS data;

END //
DELIMITER ;