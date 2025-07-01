DELIMITER //

CREATE PROCEDURE sp_view_course_content_with_progress(
    IN p_learning_program_tid BIGINT UNSIGNED,
    IN p_user_tid BIGINT UNSIGNED
)
BEGIN
    DECLARE v_enrollment_id BIGINT UNSIGNED DEFAULT NULL;
    
    -- Get enrollment ID if user is enrolled
    SELECT tid INTO v_enrollment_id
    FROM dt_learning_enrollments 
    WHERE user_tid = p_user_tid AND learning_program_tid = p_learning_program_tid;

    -- Get course basic info
    SELECT 
        lp.tid AS course_id,
        lp.title AS course_title,
        lp.description AS course_description,
        lp.difficulty_level,
        lp.image_path,
        CASE WHEN v_enrollment_id IS NOT NULL THEN le.progress_percentage ELSE 0 END AS overall_progress_percentage,
        CASE WHEN v_enrollment_id IS NOT NULL THEN le.status ELSE 'not_enrolled' END AS enrollment_status
    FROM dt_learning_programs lp
    LEFT JOIN dt_learning_enrollments le ON lp.tid = le.learning_program_tid AND le.user_tid = p_user_tid
    WHERE lp.tid = p_learning_program_tid;

    -- Get modules with their topics and progress
    SELECT 
        lm.tid AS module_id,
        lm.title AS module_title,
        lm.description AS module_description,
        lm.sequence_number AS module_sequence,
        lt.tid AS topic_id,
        lt.title AS topic_title,
        lt.description AS topic_description,
        lt.content_type,
        lt.content,
        lt.sequence_number AS topic_sequence,
        lt.progress_weight,
        CASE 
            WHEN v_enrollment_id IS NOT NULL THEN COALESCE(lp.status, 'not_started')
            ELSE 'not_enrolled'
        END AS topic_status,
        CASE 
            WHEN v_enrollment_id IS NOT NULL THEN COALESCE(lp.time_spent_minutes, 0)
            ELSE 0
        END AS time_spent_minutes,
        lp.completion_date
    FROM dt_learning_modules lm
    LEFT JOIN dt_learning_topics lt ON lm.tid = lt.module_tid
    LEFT JOIN dt_learning_progress lp ON lt.tid = lp.topic_tid AND lp.enrollment_tid = v_enrollment_id
    WHERE lm.learning_program_tid = p_learning_program_tid
    ORDER BY lm.sequence_number, lt.sequence_number;

    -- Get module-wise progress summary
    SELECT 
        lm.tid AS module_id,
        lm.title AS module_title,
        COUNT(lt.tid) AS total_topics,
        COUNT(CASE WHEN lp.status = 'completed' THEN 1 END) AS completed_topics,
        CASE 
            WHEN COUNT(lt.tid) > 0 THEN 
                ROUND((COUNT(CASE WHEN lp.status = 'completed' THEN 1 END) * 100.0) / COUNT(lt.tid), 2)
            ELSE 0
        END AS module_progress_percentage
    FROM dt_learning_modules lm
    LEFT JOIN dt_learning_topics lt ON lm.tid = lt.module_tid
    LEFT JOIN dt_learning_progress lp ON lt.tid = lp.topic_tid AND lp.enrollment_tid = v_enrollment_id
    WHERE lm.learning_program_tid = p_learning_program_tid
    GROUP BY lm.tid, lm.title, lm.sequence_number
    ORDER BY lm.sequence_number;

END //

DELIMITER ;
