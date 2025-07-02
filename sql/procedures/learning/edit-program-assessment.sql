DROP PROCEDURE IF EXISTS edit_assessment_questions;
DELIMITER //

CREATE PROCEDURE edit_assessment_questions(
    IN p_assessment_id BIGINT UNSIGNED,
    IN p_questions JSON
)
BEGIN
    DECLARE v_question_count INT DEFAULT 0;
    DECLARE v_updated_count INT DEFAULT 0;
    DECLARE v_deleted_count INT DEFAULT 0;
    DECLARE v_inserted_count INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT COALESCE(custom_error, 'An error occurred during question updates') AS message;
    END;
    
    START TRANSACTION;
    
    -- Validate assessment exists
    IF NOT EXISTS (
        SELECT 1 FROM dt_learning_assessments 
        WHERE tid = p_assessment_id
    ) THEN
        SET custom_error = CONCAT('Assessment with ID ', p_assessment_id, ' does not exist');
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Get current question count
    SELECT COUNT(*) INTO v_question_count
    FROM dt_assessment_questions
    WHERE assessment_tid = p_assessment_id;
    
    -- Process each question in the input JSON
    IF p_questions IS NOT NULL AND JSON_LENGTH(p_questions) > 0 THEN
        -- First delete questions not included in the update
        DELETE FROM dt_assessment_questions
        WHERE assessment_tid = p_assessment_id
        AND tid NOT IN (
            SELECT JSON_UNQUOTE(JSON_EXTRACT(question, '$.question_id'))
            FROM JSON_TABLE(
                p_questions,
                '$[*]' COLUMNS(
                    question JSON PATH '$'
                )
            ) AS questions
            WHERE JSON_EXTRACT(question, '$.question_id') IS NOT NULL
        );
        
        SET v_deleted_count = ROW_COUNT();
        
        -- Update existing questions
        UPDATE dt_assessment_questions q
        JOIN (
            SELECT 
                JSON_UNQUOTE(JSON_EXTRACT(question, '$.question_id')) AS question_id,
                JSON_UNQUOTE(JSON_EXTRACT(question, '$.question')) AS question_text,
                JSON_EXTRACT(question, '$.options') AS options,
                JSON_UNQUOTE(JSON_EXTRACT(question, '$.correct_option')) AS correct_option,
                JSON_EXTRACT(question, '$.score') AS score
            FROM JSON_TABLE(
                p_questions,
                '$[*]' COLUMNS(
                    question JSON PATH '$'
                )
            ) AS questions
            WHERE JSON_EXTRACT(question, '$.question_id') IS NOT NULL
        ) AS updates ON q.tid = updates.question_id
        SET 
            q.question = updates.question_text,
            q.options = updates.options,
            q.correct_option = updates.correct_option,
            q.score = IFNULL(updates.score, q.score),
            q.created_at = CURRENT_TIMESTAMP
        WHERE q.assessment_tid = p_assessment_id;
        
        SET v_updated_count = ROW_COUNT();
        
        -- Insert new questions (those without question_id)
        INSERT INTO dt_assessment_questions (
            assessment_tid,
            question,
            options,
            correct_option,
            score,
            created_at
        )
        SELECT 
            p_assessment_id,
            JSON_UNQUOTE(JSON_EXTRACT(question, '$.question')),
            JSON_EXTRACT(question, '$.options'),
            JSON_UNQUOTE(JSON_EXTRACT(question, '$.correct_option')),
            IFNULL(JSON_EXTRACT(question, '$.score'), 1),
            CURRENT_TIMESTAMP
        FROM JSON_TABLE(
            p_questions,
            '$[*]' COLUMNS(
                question JSON PATH '$'
            )
        ) AS questions
        WHERE JSON_EXTRACT(question, '$.question_id') IS NULL;
        
        SET v_inserted_count = ROW_COUNT();
    END IF;
    
    -- Update assessment question count if needed
    IF v_deleted_count > 0 OR v_inserted_count > 0 THEN
        UPDATE dt_learning_assessments
        SET question_count = (
            SELECT COUNT(*) 
            FROM dt_assessment_questions
            WHERE assessment_tid = p_assessment_id
        )
        WHERE tid = p_assessment_id;
    END IF;
    
    COMMIT;
    
    -- Return summary of changes
    SELECT JSON_OBJECT(
        'assessment_id', p_assessment_id,
        'previous_question_count', v_question_count,
        'current_question_count', v_question_count - v_deleted_count + v_inserted_count,
        'questions_updated', v_updated_count,
        'questions_deleted', v_deleted_count,
        'questions_added', v_inserted_count
    ) AS result;
END //

DELIMITER ;