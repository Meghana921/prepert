DELIMITER $$

CREATE PROCEDURE sp_view_company_subscribers(
    IN p_company_user_tid       BIGINT UNSIGNED,
    IN p_learning_program_tid   BIGINT UNSIGNED,
    IN p_status                 VARCHAR(20)
)
sp_block: BEGIN

    -- =====================================================
    -- Error handler: catches any SQL error during execution
    -- =====================================================
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- ========================================================================
    -- Main Query: Fetch all users (subscribers) enrolled in:
    --   - Programs created by the company (creator_tid = company_user_tid)
    --   - Programs sponsored by the company (via program sponsorship tables)
    --   Optionally filter by:
    --     - learning_program_tid
    --     - enrollment status
    -- ========================================================================

    SELECT 
        -- Enrollment information
        e.tid                    AS enrollment_id,
        e.user_tid,
        u.full_name              AS subscriber_name,
        u.email                  AS subscriber_email,
        u.phone                  AS subscriber_phone,

        -- Program details
        lp.tid                   AS program_id,
        lp.title                 AS program_title,
        lp.creator_tid,

        -- Enrollment progress and status
        e.status                 AS enrollment_status,
        e.progress_percentage,
        e.enrollment_date,
        e.expires_on,
        e.completed_at,
        e.certificate_issued,

        -- Sponsorship info (if any)
        us.status                AS sponsorship_status,
        ps.seats_allocated,
        ps.seats_used,

        -- Relationship type
        CASE 
            WHEN ps.tid IS NOT NULL THEN 'Sponsored'
            WHEN lp.creator_tid = p_company_user_tid THEN 'Created'
            ELSE 'Other'
        END AS relationship_type

    FROM 
        dt_learning_enrollments e
    INNER JOIN dt_users u 
        ON e.user_tid = u.tid
    INNER JOIN dt_learning_programs lp 
        ON e.learning_program_tid = lp.tid
    LEFT JOIN dt_user_sponsorships us 
        ON e.tid = us.enrollment_tid
    LEFT JOIN dt_program_sponsorships ps 
        ON us.program_sponsorship_tid = ps.tid

    -- ========================================================
    -- Filters
    -- ========================================================
    WHERE 
        (lp.creator_tid = p_company_user_tid OR ps.company_user_tid = p_company_user_tid)
        AND (p_learning_program_tid IS NULL OR lp.tid = p_learning_program_tid)
        AND (p_status IS NULL OR e.status = p_status COLLATE utf8mb4_0900_ai_ci)

    -- ========================================================
    -- Order the result to show recent enrollments first
    -- ========================================================
    ORDER BY 
        e.enrollment_date DESC,
        lp.title ASC,
        u.full_name ASC;

END sp_block $$

DELIMITER ;
call sp_view_company_subscribers(1001,3001,null);