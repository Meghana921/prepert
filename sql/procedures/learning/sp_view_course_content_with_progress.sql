DROP PROCEDURE IF EXISTS sp_view_course_content_with_progress;
DELIMITER $$

CREATE PROCEDURE sp_view_course_content_with_progress(
    IN p_learning_program_tid BIGINT UNSIGNED,
    IN p_user_tid             BIGINT UNSIGNED
)
BEGIN
    DECLARE v_enrollment_id BIGINT UNSIGNED DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', 'Error occurred while fetching course content with progress'
        ) AS data;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Get enrollment ID
    SELECT tid INTO v_enrollment_id
    FROM dt_learning_enrollments 
    WHERE user_tid = p_user_tid AND learning_program_tid = p_learning_program_tid
    LIMIT 1;

    -- Return full JSON object with all 3 parts: course info, topics with progress, and module summary
    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', JSON_OBJECT(
            'course_info',
            (
                SELECT JSON_OBJECT(
                    'course_id', lp.tid,
                    'course_title', lp.title,
                    'course_description', lp.description,
                    'difficulty_level', lp.difficulty_level,
                    'image_path', lp.image_path,
                    'overall_progress_percentage', IFNULL(le.progress_percentage, 0),
                    'enrollment_status', IFNULL(le.status, 'not_enrolled')
                )
                FROM dt_learning_programs lp
                LEFT JOIN dt_learning_enrollments le 
                    ON lp.tid = le.learning_program_tid AND le.user_tid = p_user_tid
                WHERE lp.tid = p_learning_program_tid
            ),

            'topics_with_progress',
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'module_id', lm.tid,
                        'module_title', lm.title,
                        'module_description', lm.description,
                        'module_sequence', lm.sequence_number,
                        'topic_id', lt.tid,
                        'topic_title', lt.title,
                        'topic_description', lt.description,
                        'content_type', lt.content_type,
                        'content', lt.content,
                        'topic_sequence', lt.sequence_number,
                        'progress_weight', lt.progress_weight,
                        'topic_status', IFNULL(lp.status, 'not_started'),
                        'time_spent_minutes', IFNULL(lp.time_spent_minutes, 0),
                        'completion_date', lp.completion_date
                    )
                )
                FROM dt_learning_modules lm
                LEFT JOIN dt_learning_topics lt ON lm.tid = lt.module_tid
                LEFT JOIN dt_learning_progress lp 
                    ON lt.tid = lp.topic_tid AND lp.enrollment_tid = v_enrollment_id
                WHERE lm.learning_program_tid = p_learning_program_tid
                ORDER BY lm.sequence_number, lt.sequence_number
            ),

            'module_progress_summary',
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'module_id', lm.tid,
                        'module_title', lm.title,
                        'total_topics', COUNT(lt.tid),
                        'completed_topics', COUNT(CASE WHEN lp.status = 'completed' THEN 1 END),
                        'module_progress_percentage',
                            CASE
                                WHEN COUNT(lt.tid) > 0 THEN 
                                    ROUND((COUNT(CASE WHEN lp.status = 'completed' THEN 1 END) * 100.0) / COUNT(lt.tid), 2)
                                ELSE 0
                            END
                    )
                )
                FROM dt_learning_modules lm
                LEFT JOIN dt_learning_topics lt ON lm.tid = lt.module_tid
                LEFT JOIN dt_learning_progress lp 
                    ON lt.tid = lp.topic_tid AND lp.enrollment_tid = v_enrollment_id
                WHERE lm.learning_program_tid = p_learning_program_tid
                GROUP BY lm.tid, lm.title
                ORDER BY lm.sequence_number
            )
        )
    ) AS data;

    COMMIT;
END $$

DELIMITER ;
