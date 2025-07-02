DELIMITER $$

CREATE PROCEDURE sp_list_subscribed_courses(
    IN p_user_tid BIGINT UNSIGNED
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- List all subscribed/enrolled courses for a user with course details
    SELECT 
        e.tid AS enrollment_id,
        e.user_tid,
        e.learning_program_tid,
        lp.title AS course_title,
        lp.description AS course_description,
        lp.difficulty_level,
        lp.image_path,
        lp.price,
        lp.access_period_months,
        lp.campus_hiring,
        lp.sponsored,
        lp.employer_name,
        e.status AS enrollment_status,
        e.progress_percentage,
        e.enrollment_date,
        e.expires_on,
        e.completed_at,
        e.certificate_issued,
        e.certificate_url,
        -- Creator information
        u.full_name AS creator_name,
        u.email AS creator_email,
        -- Calculate days remaining for access
        CASE 
            WHEN e.expires_on IS NOT NULL THEN
                GREATEST(0, DATEDIFF(e.expires_on, CURDATE()))
            ELSE NULL
        END AS days_remaining,
        -- Check if course is expired
        CASE 
            WHEN e.expires_on IS NOT NULL AND e.expires_on < CURDATE() THEN TRUE
            ELSE FALSE
        END AS is_expired
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

CALL sp_list_subscribed_courses(2001);
