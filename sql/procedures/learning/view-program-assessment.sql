DROP PROCEDURE IF EXISTS view_program_assessment;
DELIMITER //

CREATE PROCEDURE view_program_assessment(
    IN in_program_id BIGINT UNSIGNED
)
BEGIN
    DECLARE json_result JSON;
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;

    -- Handle SQL exceptions with a rollback and custom error message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET custom_error = COALESCE(custom_error, 'Failed to fetch assessment');
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END;

    -- Check if an assessment exists for the given program
    IF NOT EXISTS (
        SELECT 1 FROM dt_learning_assessments WHERE learning_program_tid = in_program_id
    ) THEN
        SET custom_error = 'Assessment not found for the given program';
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END IF;

    -- Build a JSON response combining assessment info and associated questions
    SELECT 
        JSON_OBJECT(
            'assessment_id', a.tid,
            'title', a.title,
            'description', a.description,
            'question_count', a.question_count,
            'passing_score', a.passing_score,
            'questions', IFNULL(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'question_id', q.tid,
                            'question', q.question,
                            'options', q.options,
                            'correct_option', q.correct_option,
                            'score', q.score
                        )
                    )
                    FROM dt_assessment_questions q
                    WHERE q.assessment_tid = a.tid
                ),
                JSON_ARRAY()
            ),
            'created_at', a.created_at,
            'updated_at', a.updated_at
        ) 
        INTO json_result
    FROM dt_learning_assessments a
    WHERE a.learning_program_tid = in_program_id;

    -- Return the final JSON result
    SELECT json_result AS data;
END //
DELIMITER ;
