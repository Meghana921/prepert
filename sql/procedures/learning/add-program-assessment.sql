DROP PROCEDURE IF EXISTS add_learning_assessment;

DELIMITER //
CREATE PROCEDURE add_learning_assessment (
    IN in_program_id BIGINT UNSIGNED,
    IN in_title VARCHAR(100),
    IN in_description TEXT,
    IN in_question_count SMALLINT UNSIGNED,
    IN in_passing_score TINYINT UNSIGNED,
    IN in_questions JSON
) BEGIN DECLARE assessment_id BIGINT UNSIGNED;

DECLARE questions_added INT UNSIGNED DEFAULT 0;

DECLARE custom_error VARCHAR(255);

DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;

SELECT
    COALESCE(
        custom_error,
        'An error occurred during assessment creation'
    ) AS message;

END;

START TRANSACTION;

IF NOT EXISTS (
    SELECT
        1
    FROM
        dt_learning_programs
    WHERE
        tid = in_program_id
    LIMIT
        1
) THEN
SET
    custom_error = CONCAT (
        'Learning program with ID ',
        in_program_id,
        ' does not exist'
    );

SIGNAL SQLSTATE '45000';

END IF;

IF EXISTS (
    SELECT
        1
    FROM
        dt_learning_assessments
    WHERE
        learning_program_tid = in_program_id
) THEN
SET
    custom_error = 'Assessment for this program has already been created. You can access and update it if necessary ';

SIGNAL SQLSTATE '45000';

END IF;

INSERT INTO
    dt_learning_assessments (
        learning_program_tid,
        title,
        description,
        question_count,
        passing_score,
        created_at,
        updated_at
    )
VALUES
    (
        in_program_id,
        in_title,
        in_description,
        in_question_count,
        in_passing_score,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

SET
    assessment_id = LAST_INSERT_ID ();

IF in_questions IS NOT NULL
AND JSON_LENGTH (in_questions) > 0 THEN
INSERT INTO
    dt_assessment_questions (
        assessment_tid,
        question,
        options,
        correct_option,
        score,
        created_at
    )
SELECT
    assessment_id,
    question,
    options,
    correct_option,
    IFNULL (score, 1),
    CURRENT_TIMESTAMP
FROM
    JSON_TABLE (
        in_questions,
        '$[*]' COLUMNS (
            question TEXT PATH '$.question',
            options JSON PATH '$.options',
            correct_option TEXT PATH '$.correct_option',
            score INT PATH '$.score'
        )
    ) AS questions;

SET
    questions_added = ROW_COUNT ();

END IF;

SELECT
    JSON_OBJECT (
        'assessment_id',
        assessment_id,
        'total_questions',
        questions_added
    ) as data;

COMMIT;

END //
DELIMITER ;

CALL add_learning_assessment (
    1, -- in_program_id (must exist in dt_learning_programs)
    'Basic Math Assessment', -- in_title
    'Test your basic math skills', -- in_description
    3, -- in_question_count (should match number of questions)
    70, -- in_passing_score (percentage)
    JSON_ARRAY ( -- in_questions (array of question objects)
        JSON_OBJECT (
            'question',
            'What is 2 + 2?',
            'options',
            JSON_ARRAY ('3', '4', '5', '6'),
            'correct_option',
            '4',
            'score',
            1
        ),
        JSON_OBJECT (
            'question',
            'What is 5 × 7?',
            'options',
            JSON_ARRAY ('25', '30', '35', '40'),
            'correct_option',
            '35',
            'score',
            1
        ),
        JSON_OBJECT (
            'question',
            'What is 10 ÷ 2?',
            'options',
            JSON_ARRAY ('2', '5', '8', '10'),
            'correct_option',
            '5',
            'score',
            1
        )
    )
);