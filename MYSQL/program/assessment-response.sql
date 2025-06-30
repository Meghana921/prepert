DROP PROCEDURE IF EXISTS sp_submit_assessment_responses;
DROP PROCEDURE IF EXISTS sp_submit_assessment_responses;
DELIMITER //

CREATE PROCEDURE sp_submit_assessment_responses(
    IN p_assessment_id BIGINT UNSIGNED,
    IN p_user_id BIGINT UNSIGNED,
    IN p_responses JSON
)
BEGIN
    DECLARE v_attempt_id BIGINT UNSIGNED;
    DECLARE v_total_questions INT;
    DECLARE v_correct_answers INT DEFAULT 0;
    DECLARE v_passing_score INT;
    DECLARE v_obtained_score INT DEFAULT 0;
    DECLARE v_attempt_number INT;
    
    -- Create new attempt (always create new for multiple attempts)
    INSERT INTO dt_assessment_attempts (
        assessment_tid, 
        user_tid, 
        started_at
    ) VALUES (
        p_assessment_id, 
        p_user_id, 
        CURRENT_TIMESTAMP
    );
    
    SET v_attempt_id = LAST_INSERT_ID();
    
    -- Get assessment details
    SELECT 
        passing_score, 
        question_count
    INTO 
        v_passing_score, 
        v_total_questions
    FROM dt_learning_assessments
    WHERE tid = p_assessment_id;
    
    -- Get attempt number using COUNT(tid)
    SELECT COUNT(tid) INTO v_attempt_number
    FROM dt_assessment_attempts
    WHERE assessment_tid = p_assessment_id 
    AND user_tid = p_user_id;
    
    -- Insert responses and calculate correctness
    INSERT INTO dt_assessment_responses (
        attempt_tid, 
        question_tid, 
        selected_option, 
        is_correct,
        score
    )
    SELECT 
        v_attempt_id,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(response, '$.question_id')) AS UNSIGNED),
        JSON_UNQUOTE(JSON_EXTRACT(response, '$.selected_option')),
        (JSON_UNQUOTE(JSON_EXTRACT(response, '$.selected_option')) = aq.correct_option),
        CASE 
            WHEN JSON_UNQUOTE(JSON_EXTRACT(response, '$.selected_option')) = aq.correct_option 
            THEN aq.score 
            ELSE 0 
        END
    FROM 
        JSON_TABLE(p_responses, '$[*]' COLUMNS(
            response JSON PATH '$'
        )) AS r
    JOIN 
        dt_assessment_questions aq ON aq.tid = CAST(JSON_UNQUOTE(JSON_EXTRACT(response, '$.question_id')) AS UNSIGNED)
    WHERE 
        aq.assessment_tid = p_assessment_id;
    
    -- Calculate obtained score
    SELECT SUM(score) INTO v_obtained_score
    FROM dt_assessment_responses
    WHERE attempt_tid = v_attempt_id;
    
    -- Count correct answers using COUNT(tid)
    SELECT COUNT(tid) INTO v_correct_answers
    FROM dt_assessment_responses
    WHERE attempt_tid = v_attempt_id AND is_correct = TRUE;
    
    -- Update attempt with final score
    UPDATE dt_assessment_attempts
    SET 
        score = v_obtained_score,
        passed = (v_obtained_score >= v_passing_score),
        completed_at = CURRENT_TIMESTAMP
    WHERE tid = v_attempt_id;
    
    -- Return results as JSON in the requested format
    SELECT JSON_OBJECT(
        'attempt_id', v_attempt_id,
        'marks_obtained', v_obtained_score,
        'passing_score', v_passing_score,
        'is_passed', (v_obtained_score >= v_passing_score),
        'attempt_number', v_attempt_number
    ) AS result;
END //

DELIMITER ;

DELIMITER ;
CALL sp_submit_assessment_responses(
    1,  -- assessment_id
    123, -- user_id
    JSON_ARRAY(
        JSON_OBJECT("question_id", 1, "selected_option", "4"),
        JSON_OBJECT("question_id", 2, "selected_option", "9")
    )
);
