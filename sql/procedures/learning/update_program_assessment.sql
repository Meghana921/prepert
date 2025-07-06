DROP PROCEDURE IF EXISTS update_program_assessment;
DELIMITER //

CREATE PROCEDURE update_program_assessment (
    IN in_assessment_id BIGINT UNSIGNED,
    IN in_title VARCHAR(100),
    IN in_description TEXT,
    IN in_question_count SMALLINT UNSIGNED,
    IN in_passing_score TINYINT UNSIGNED,
    IN in_questions JSON
)
BEGIN
    -- Variable to track how many questions were inserted
    DECLARE questions_added INT DEFAULT 0;

    -- Start a transaction to ensure atomicity
    START TRANSACTION;

    -- Step 1: Update assessment information in dt_learning_assessments
    UPDATE dt_learning_assessments
    SET
        title = in_title,
        description = in_description,
        question_count = in_question_count,
        passing_score = in_passing_score
    WHERE tid = in_assessment_id;

    -- Step 2: Delete all existing questions related to the given assessment
    DELETE FROM dt_assessment_questions
    WHERE assessment_tid = in_assessment_id;

    -- Step 3: Insert new questions from the JSON array if provided
    IF in_questions IS NOT NULL AND JSON_LENGTH(in_questions) > 0 THEN
        INSERT INTO dt_assessment_questions (
            assessment_tid,
            question,
            options,
            correct_option,
            score,
            sequence_number
        )
        SELECT
            in_assessment_id,
            question,
            options,
            correct_option,
            IFNULL(score, 1),
            sequence_number  -- Assigns sequential number to each question
        FROM JSON_TABLE (
            in_questions,
            '$[*]' COLUMNS (
                question TEXT PATH '$.question',
                options JSON PATH '$.options',
                correct_option SMALLINT PATH '$.correct_option',
                score TINYINT PATH '$.score',
                sequence_number TINYINT PATH '$.sequence_number'
            )
        ) AS q;

        -- Count how many rows were inserted
        SET questions_added = ROW_COUNT();
    END IF;

    -- Step 4: Commit all changes
    COMMIT;

    -- Step 5: Return a structured JSON response with assessment ID and question count
    SELECT JSON_OBJECT(
        'assessment_id', in_assessment_id,
        'updated_question_count', questions_added
    ) AS data;
END;
//
DELIMITER ;
