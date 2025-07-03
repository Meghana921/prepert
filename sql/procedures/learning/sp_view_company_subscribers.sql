DROP PROCEDURE IF EXISTS sp_view_company_subscribers;
DELIMITER $$

CREATE PROCEDURE sp_view_company_subscribers(
    IN p_company_user_tid     BIGINT UNSIGNED,
    IN p_learning_program_tid BIGINT UNSIGNED,
    IN p_status               VARCHAR(20)
)
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(v_error_message, 'An error occurred while fetching subscribers')
        ) AS data;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'enrollment_id',         e.tid,
                        'user_id',               e.user_tid,
                        'subscriber_name',       u.full_name,
                        'subscriber_email',      u.email,
                        'subscriber_phone',      u.phone,
                        'program_id',            lp.tid,
                        'program_title',         lp.title,
                        'enrollment_status',     e.status,
                        'progress_percentage',   e.progress_percentage,
                        'enrollment_date',       e.enrollment_date,
                        'expires_on',            e.expires_on,
                        'completed_at',          e.completed_at,
                        'certificate_issued',    e.certificate_issued,
                        'sponsorship_status',    us.status,
                        'seats_allocated',       ps.seats_allocated,
                        'seats_used',            ps.seats_used,
                        'relationship_type',     CASE 
                                                    WHEN ps.tid IS NOT NULL THEN 'Sponsored'
                                                    WHEN lp.creator_tid = p_company_user_tid THEN 'Created'
                                                    ELSE 'Other'
                                                 END
                    )
                )
                FROM dt_learning_enrollments e
                INNER JOIN dt_users u 
                    ON e.user_tid = u.tid
                INNER JOIN dt_learning_programs lp 
                    ON e.learning_program_tid = lp.tid
                LEFT JOIN dt_user_sponsorships us 
                    ON e.tid = us.enrollment_tid
                LEFT JOIN dt_program_sponsorships ps 
                    ON us.program_sponsorship_tid = ps.tid
                WHERE 
                    (lp.creator_tid = p_company_user_tid OR ps.company_user_tid = p_company_user_tid)
                    AND (p_learning_program_tid IS NULL OR lp.tid = p_learning_program_tid)
                    AND (p_status IS NULL OR e.status = p_status)
                ORDER BY 
                    e.enrollment_date DESC,
                    lp.title ASC,
                    u.full_name ASC
            ),
            JSON_ARRAY()
        )
    ) AS data;

    COMMIT;
END $$

DELIMITER ;

-- Example:
CALL sp_view_company_subscribers(1001, 3001, NULL);
