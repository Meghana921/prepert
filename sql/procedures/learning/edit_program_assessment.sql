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

    DECLARE questions_added INT DEFAULT 0;
    
    START TRANSACTION;


    -- Step 3: Update assessment info
    UPDATE dt_learning_assessments
    SET
        title = in_title,
        description = in_description,
        question_count = in_question_count,
        passing_score = in_passing_score
    WHERE tid = in_assessment_id;

    -- Step 4: Delete existing questions (if any)
    DELETE FROM dt_assessment_questions
    WHERE assessment_tid = in_assessment_id;

    -- Step 5: Insert new questions
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
            ROW_NUMBER() OVER () -- sequence_number
        FROM JSON_TABLE (
            in_questions,
            '$[*]' COLUMNS (
                question TEXT PATH '$.question',
                options JSON PATH '$.options',
                correct_option SMALLINT PATH '$.correct_option',
                score INT PATH '$.score'
            )
        ) AS q;

        SET questions_added = ROW_COUNT();
    END IF;

    COMMIT;

    -- Step 6: Return final result
    SELECT JSON_OBJECT(
        'assessment_id', in_assessment_id,
        'updated_question_count', questions_added
    ) AS data;

END;
//
DELIMITER ;
