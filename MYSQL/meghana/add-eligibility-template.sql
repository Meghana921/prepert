DROP PROCEDURE IF EXISTS add_eligibility_template;

DELIMITER //

 CREATE PROCEDURE add_eligibility_template (
    IN in_creator_id BIGINT,
    IN in_template_name VARCHAR(100),
    IN in_eligibility_questions JSON
) 
BEGIN DECLARE custom_error VARCHAR(255);

DECLARE eligibility_template_tid BIGINT;

DECLARE duplicate_count INT DEFAULT 0;

DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;

SELECT
    COALESCE(
        custom_error,
        "An error occurred while inserting template"
    ) as message;

END;

START TRANSACTION;

-- Check if template already exists
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
        ' - template already exists! You can view and edit template'
    );

SIGNAL SQLSTATE '45000';

END IF;

-- Insert new template
INSERT INTO
    dt_eligibility_templates (creator_tid, name)
VALUES
    (in_creator_id, in_template_name);

SET
    eligibility_template_tid = LAST_INSERT_ID ();

-- Insert questions using JSON_TABLE 
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
            deciding_answer ENUM ("yes", "no") PATH '$.deciding_answer', -- Fixed path
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
            question,
            COUNT(tid) AS cnt
        FROM
            dt_eligibility_questions
        WHERE
            template_tid = eligibility_template_tid
        GROUP BY
            question
        HAVING
            cnt > 1
    ) AS duplicates;

IF duplicate_count > 0 THEN
SET
    custom_error = 'Duplicate questions found in the template';

SIGNAL SQLSTATE '45000';

END IF;

SELECT
    JSON_OBJECT (
        "template_id",
        eligibility_template_tid,
        "template_name",
        in_template_name
    ) AS data;

COMMIT;

END //
DELIMITER ;

