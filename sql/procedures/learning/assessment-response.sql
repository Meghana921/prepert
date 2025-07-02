DROP PROCEDURE IF EXISTS submit_program_assessment;
DELIMITER //

CREATE PROCEDURE submit_program_assessment(
    IN p_user_id BIGINT UNSIGNED,
    IN p_program_id BIGINT UNSIGNED,
    IN p_responses JSON
)
BEGIN
    DECLARE v_enrollment_id BIGINT UNSIGNED;
    DECLARE v_assessment_id BIGINT UNSIGNED;
    DECLARE v_attempt_id BIGINT UNSIGNED;
    DECLARE v_total_score INT DEFAULT 0;
    DECLARE v_question_count INT DEFAULT 0;
    DECLARE v_passing_score INT;
    DECLARE v_passed BOOLEAN DEFAULT FALSE;
    
    SELECT tid INTO v_enrollment_id
    FROM dt_learning_enrollments
    WHERE user_tid = p_user_id 
    AND learning_program_tid = p_program_id
    AND status IN ('completed')
    LIMIT 1;
    

    SELECT tid INTO v_assessment_id
    FROM dt_learning_assessments
    WHERE learning_program_tid = p_program_id
    LIMIT 1;
    
    -- Create new attempt record
    INSERT INTO dt_assessment_attempts (
        assessment_tid,
        user_tid,
        enrollment_tid,
        started_at
    ) VALUES (
        v_assessment_id,
        p_user_id,
        v_enrollment_id,
        CURRENT_TIMESTAMP
    );
    
    SET v_attempt_id = LAST_INSERT_ID();
    
    -- Get assessment requirements
    SELECT question_count, passing_score 
    INTO v_question_count, v_passing_score
    FROM dt_learning_assessments 
    WHERE tid = v_assessment_id;
    
    -- Process each response
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
        '$[*]' COLUMNS(
            response JSON PATH '$'
        )
    ) AS responses;
    
    -- Calculate total score
    SELECT SUM(score) INTO v_total_score
    FROM dt_assessment_responses
    WHERE attempt_tid = v_attempt_id;
    
    -- Determine pass/fail status
    SET v_passed = (v_total_score >= v_passing_score);
    
    -- Update attempt with final results
    UPDATE dt_assessment_attempts
    SET 
        score = v_total_score,
        passed = v_passed,
        completed_at = CURRENT_TIMESTAMP
    WHERE tid = v_attempt_id;
    
    -- Update enrollment progress if passed
    IF v_passed THEN
        UPDATE dt_learning_enrollments
        SET 
            progress_percentage = 100,
            status = 'completed',
            completed_at = CURRENT_TIMESTAMP
        WHERE tid = v_enrollment_id;
    END IF;
    
    -- Return comprehensive results
    SELECT JSON_OBJECT(
        'attempt_id', v_attempt_id,
        'user_id', p_user_id,
        'enrollment_id', v_enrollment_id,
        'assessment_id', v_assessment_id,
        'total_score', v_total_score,
        'max_possible_score', v_question_count,
        'passed', v_passed,
        'completion_time', CURRENT_TIMESTAMP,
        'responses', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'question_id', r.question_tid,
                    'selected_option', r.selected_option,
                    'correct_option', q.correct_option,
                    'is_correct', r.is_correct,
                    'score_earned', r.score,
                    'max_score', q.score
                )
            )
            FROM dt_assessment_responses r
            JOIN dt_assessment_questions q ON r.question_tid = q.tid
            WHERE r.attempt_tid = v_attempt_id
        )
    ) AS assessment_result;
END //

DELIMITER ;

CALL submit_user_assessment(
    5,  -- user ID
    1,  -- program ID
    '[
        {"question_id": 13, "selected_option": "Paris"},
        {"question_id": 14, "selected_option": "SQL"},
        {"question_id": 15, "selected_option": "False"}
    ]'
);