DROP PROCEDURE IF EXISTS sp_list_subscribed_courses;
DELIMITER $$

CREATE PROCEDURE sp_list_subscribed_courses(
    IN p_user_tid BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', 'An error occurred while retrieving subscribed courses'
        ) AS data;
        ROLLBACK;
      
    END;

    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'enrollment_id', e.tid,
                    'program_id', e.learning_program_tid,
                    'course_title', lp.title,
                    'course_description', lp.description,
                    'difficulty_level', lp.difficulty_level,
                    'image_path', lp.image_path,
                    'price', lp.price,
                    'access_period_months', lp.access_period_months,
                    'campus_hiring', lp.campus_hiring,
                    'sponsored', lp.sponsored,
                    'employer_name', lp.employer_name,
                    'enrollment_status', e.status,
                    'progress_percentage', e.progress_percentage,
                    'enrollment_date', e.enrollment_date,
                    'expires_on', e.expires_on,
                    'completed_at', e.completed_at,
                    'certificate_issued', e.certificate_issued,
                    'certificate_url', e.certificate_url,
                    'creator_name', u.full_name,
                    'creator_email', u.email,
                    'days_remaining', CASE 
                        WHEN e.expires_on IS NOT NULL THEN GREATEST(0, DATEDIFF(e.expires_on, CURDATE()))
                        ELSE NULL
                    END,
                    'is_expired', CASE 
                        WHEN e.expires_on IS NOT NULL AND e.expires_on < CURDATE() THEN TRUE
                        ELSE FALSE
                    END
                )
            ),
            JSON_ARRAY()
        )
    ) AS data
    FROM 
        dt_learning_enrollments e
    INNER JOIN 
        dt_learning_programs lp ON e.learning_program_tid = lp.tid
    INNER JOIN 
        dt_users u ON lp.creator_tid = u.tid
    WHERE 
        e.user_tid = p_user_tid
    ORDER BY 
        e.enrollment_date DESC, 
        e.status ASC,
        lp.title ASC;

END$$

DELIMITER ;
