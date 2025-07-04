DROP PROCEDURE IF EXISTS add_eligibility_template;

DELIMITER //
 CREATE PROCEDURE add_eligibility_template (
    IN in_creator_id BIGINT,
    IN in_template_name VARCHAR(100),
    IN in_eligibility_questions JSON
) BEGIN DECLARE custom_error VARCHAR(255) DEFAULT NULL;

DECLARE eligibility_template_tid BIGINT;

DECLARE duplicate_count INT DEFAULT 0;

-- Error Handler
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;

SELECT
    COALESCE(
        custom_error,
        'An error occurred while inserting template'
    ) as message;

END;

START TRANSACTION;

-- Check for duplicate template name by creator
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
    custom_error = CONCAT (
        in_template_name,
        ' - An entry with the given template name already exists. Kindly refer to the existing version for updates'
    );

SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = custom_error;

END IF;

-- Insert new template
INSERT INTO
    dt_eligibility_templates (creator_tid, name)
VALUES
    (in_creator_id, in_template_name);

SET
    eligibility_template_tid = LAST_INSERT_ID ();

-- Insert all questions
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
    q.deciding_answer,
    q.sequence_number
FROM
    JSON_TABLE (
        in_eligibility_questions,
        '$[*]' COLUMNS (
            question TEXT PATH '$.question',
            deciding_answer ENUM ('yes', 'no') PATH '$.deciding_answer',
            sequence_number INT PATH '$.sequence_number',
            question_id FOR ORDINALITY
        )
    ) AS q
WHERE
    q.question IS NOT NULL;

-- Check for duplicate questions
SELECT
    COUNT(*) INTO duplicate_count
FROM
    (
        SELECT
            question
        FROM
            dt_eligibility_questions
        WHERE
            template_tid = eligibility_template_tid
        GROUP BY
            question
        HAVING
            COUNT(*) > 1
    ) AS duplicates;

IF duplicate_count > 0 THEN
SET
    custom_error = 'Duplicate questions found in the template';

SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = custom_error;

END IF;

COMMIT;

-- Return final JSON response
SELECT
  
        JSON_OBJECT (
            'template_id',
            eligibility_template_tid,
            'template_name',
            in_template_name
        
    ) AS data;

END //
DELIMITER ;