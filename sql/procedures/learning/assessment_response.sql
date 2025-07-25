DROP PROCEDURE IF EXISTS submit_program_assessment;
DELIMITER //

-- Submits a user's responses to a program-level assessment, evaluates score, and records result
CREATE PROCEDURE submit_program_assessment(
    IN p_user_id BIGINT UNSIGNED,
    IN p_assessment_id BIGINT UNSIGNED,
    IN p_responses JSON
)
BEGIN
    DECLARE v_enrollment_id BIGINT UNSIGNED;
    DECLARE v_attempt_id BIGINT UNSIGNED;
    DECLARE v_total_score INT DEFAULT 0;
    DECLARE v_question_count INT DEFAULT 0;
    DECLARE v_passing_score INT;
    DECLARE v_passed BOOLEAN DEFAULT FALSE;
    DECLARE custom_error VARCHAR(255);

    -- Exit handler to rollback and return error message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT COALESCE(custom_error, 'An error occurred during assessment submission') AS message;
    END;

    START TRANSACTION;

    -- Get total number of questions and passing score for the assessment
    SELECT question_count, passing_score
    INTO v_question_count, v_passing_score
    FROM dt_learning_assessments
    WHERE tid = p_assessment_id
    LIMIT 1;

    -- Retrieve the enrollment ID for the user under the same learning program as the assessment
    SELECT tid INTO v_enrollment_id
    FROM dt_learning_enrollments
    WHERE user_tid = p_user_id
      AND learning_program_tid = (
        SELECT learning_program_tid 
        FROM dt_learning_assessments 
        WHERE tid = p_assessment_id
      )
    LIMIT 1;

    -- Insert a new assessment attempt
    INSERT INTO dt_assessment_attempts (
        assessment_tid,
        user_tid,
        enrollment_tid
    ) VALUES (
        p_assessment_id,
        p_user_id,
        v_enrollment_id
    );

    SET v_attempt_id = LAST_INSERT_ID();

    -- Store the responses provided by the user with evaluation
    INSERT INTO dt_assessment_responses (
        attempt_tid,
        question_tid,
        selected_option,
        is_correct,
        score
    )
    SELECT
        v_attempt_id,
        JSON_UNQUOTE(JSON_EXTRACT(response, '$.question_id')),
        JSON_UNQUOTE(JSON_EXTRACT(response, '$.selected_option')),
        (
            SELECT JSON_UNQUOTE(JSON_EXTRACT(response, '$.selected_option')) = q.correct_option
            FROM dt_assessment_questions q
            WHERE q.tid = JSON_UNQUOTE(JSON_EXTRACT(response, '$.question_id'))
        ),
        (
            SELECT IF(
                JSON_UNQUOTE(JSON_EXTRACT(response, '$.selected_option')) = q.correct_option,
                q.score,
                0
            )
            FROM dt_assessment_questions q
            WHERE q.tid = JSON_UNQUOTE(JSON_EXTRACT(response, '$.question_id'))
        )
    FROM JSON_TABLE(
        p_responses,
        '$[*]' COLUMNS (
            response JSON PATH '$'
        )
    ) AS responses;

    -- Calculate total score for the attempt
    SELECT SUM(score) INTO v_total_score
    FROM dt_assessment_responses
    WHERE attempt_tid = v_attempt_id;

    -- Determine whether the user passed based on the total score
    SET v_passed = (v_total_score >= v_passing_score);

    -- Update the assessment attempt record with score, status, and completion time
    UPDATE dt_assessment_attempts
    SET 
        score = v_total_score,
        passed = v_passed,
        completed_at = CURRENT_TIMESTAMP
    WHERE tid = v_attempt_id;

    -- Return final response as JSON
    SELECT JSON_OBJECT(
        'user_tid', p_user_id,
        'assessment_id', p_assessment_id,
        'total_score', v_total_score,
        'passed', v_passed
    ) AS data;

    COMMIT;
END;
//
DELIMITER ;
