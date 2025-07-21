DROP PROCEDURE IF EXISTS update_program_assessment;
DELIMITER //

-- Updates assessment details and replaces its questions using the provided JSON input
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
    DECLARE custom_error VARCHAR(255);
    DECLARE error_message VARCHAR(255);

    -- Error handler to rollback and raise a custom error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        SET custom_error = COALESCE(custom_error, error_message);
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = custom_error;
    END;

    START TRANSACTION;

    -- Validate that the assessment exists
    IF NOT EXISTS (
        SELECT 1 FROM dt_learning_assessments WHERE tid = in_assessment_id
    ) THEN
        SET custom_error = 'Assessment not found!';
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END IF;

    -- Update basic details of the assessment
    UPDATE dt_learning_assessments
    SET
        title = in_title,
        description = in_description,
        question_count = in_question_count,
        passing_score = in_passing_score
    WHERE tid = in_assessment_id;

    -- Remove existing questions for this assessment
    DELETE FROM dt_assessment_questions
    WHERE assessment_tid = in_assessment_id;

    -- Insert new questions if provided
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
            sequence_number  
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

        SET questions_added = ROW_COUNT();
    END IF;

    COMMIT;

    -- Return a structured response
    SELECT JSON_OBJECT(
        'assessment_id', in_assessment_id,
        'updated_question_count', questions_added
    ) AS data;
END;
//
DELIMITER ;
