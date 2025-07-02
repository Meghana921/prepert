DELIMITER $$

CREATE PROCEDURE sp_view_all_learning_courses(
    IN p_creator_tid       BIGINT UNSIGNED ,  -- Optional filter: creator user ID
    IN p_difficulty_level  VARCHAR(20)     ,  -- Optional filter: difficulty ('low', 'medium', etc.)
    IN p_sponsored         BOOLEAN         ,  -- Optional filter: sponsored courses only
    IN p_limit             INT             ,  -- Pagination: number of records to return
    IN p_offset            INT                -- Pagination: number of records to skip
)
BEGIN
	
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT 
        lp.tid                     AS program_id,
        lp.title,
        lp.description,
        lp.creator_tid,
        u.full_name               AS creator_name,
        u.email                   AS creator_email,
        lp.difficulty_level,
        lp.image_path,
        lp.price,
        lp.access_period_months,
        lp.available_slots,
        lp.campus_hiring,
        lp.sponsored,
        lp.minimum_score,
        lp.experience_from,
        lp.experience_to,
        lp.locations,
        lp.employer_name,
        lp.created_at,
        lp.updated_at,
        COUNT(DISTINCT e.tid)     AS enrollment_count,
        COUNT(DISTINCT m.tid)     AS module_count,
        COUNT(DISTINCT t.tid)     AS topic_count,
        COUNT(DISTINCT a.tid)     AS assessment_count

    FROM 
        dt_learning_programs lp

    LEFT JOIN dt_users u 
        ON lp.creator_tid = u.tid

    LEFT JOIN dt_learning_enrollments e 
        ON lp.tid = e.learning_program_tid

    LEFT JOIN dt_learning_modules m 
        ON lp.tid = m.learning_program_tid

    LEFT JOIN dt_learning_topics t 
        ON m.tid = t.module_tid

    LEFT JOIN dt_learning_assessments a 
        ON lp.tid = a.learning_program_tid

    WHERE 
        (p_creator_tid IS NULL OR lp.creator_tid = p_creator_tid)
        AND (p_difficulty_level IS NULL OR lp.difficulty_level = p_difficulty_level COLLATE utf8mb4_0900_ai_ci)
        AND (p_sponsored IS NULL OR lp.sponsored = p_sponsored)

    GROUP BY 
        lp.tid, lp.title, lp.description, lp.creator_tid,
        u.full_name, u.email,
        lp.difficulty_level, lp.image_path, lp.price, lp.access_period_months,
        lp.available_slots, lp.campus_hiring, lp.sponsored, lp.minimum_score,
        lp.experience_from, lp.experience_to, lp.locations, lp.employer_name,
        lp.created_at, lp.updated_at

    ORDER BY 
        lp.created_at DESC
    LIMIT p_limit OFFSET p_offset;

END $$

DELIMITER ;
CALL sp_view_all_learning_courses(1001, NULL, NULL, 50, 0);

