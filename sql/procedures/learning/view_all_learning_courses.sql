DROP PROCEDURE IF EXISTS sp_view_all_learning_courses;
DELIMITER $$

CREATE PROCEDURE sp_view_all_learning_courses(
    IN p_creator_tid       BIGINT UNSIGNED,  -- Optional filter: creator user ID
    IN p_difficulty_level  VARCHAR(20),      -- Optional filter: difficulty ('low', 'medium', etc.)
    IN p_sponsored         BOOLEAN,          -- Optional filter: sponsored only
    IN p_limit             INT,              -- Pagination: how many
    IN p_offset            INT               -- Pagination: skip how many
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', 'Database error occurred while fetching course list'
        ) AS data;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', COALESCE(
            (
                SELECT JSON_ARRAYAGG(course_data)
                FROM (
                    SELECT JSON_OBJECT(
                        'program_id',        lp.tid,
                        'title',             lp.title,
                        'description',       lp.description,
                        'creator_id',        lp.creator_tid,
                        'creator_name',      u.full_name,
                        'creator_email',     u.email,
                        'difficulty_level',  lp.difficulty_level,
                        'image_path',        lp.image_path,
                        'price',             lp.price,
                        'access_period_months', lp.access_period_months,
                        'available_slots',   lp.available_slots,
                        'campus_hiring',     lp.campus_hiring,
                        'sponsored',         lp.sponsored,
                        'minimum_score',     lp.minimum_score,
                        'experience_from',   lp.experience_from,
                        'experience_to',     lp.experience_to,
                        'locations',         lp.locations,
                        'employer_name',     lp.employer_name,
                        'created_at',        lp.created_at,
                        'updated_at',        lp.updated_at,
                        'enrollment_count',  COUNT(DISTINCT e.tid),
                        'module_count',      COUNT(DISTINCT m.tid),
                        'topic_count',       COUNT(DISTINCT t.tid),
                        'assessment_count',  COUNT(DISTINCT a.tid)
                    ) AS course_data
                    FROM dt_learning_programs lp
                    LEFT JOIN dt_users u                 ON lp.creator_tid = u.tid
                    LEFT JOIN dt_learning_enrollments e ON lp.tid = e.learning_program_tid
                    LEFT JOIN dt_learning_modules m     ON lp.tid = m.learning_program_tid
                    LEFT JOIN dt_learning_topics t      ON m.tid = t.module_tid
                    LEFT JOIN dt_learning_assessments a ON lp.tid = a.learning_program_tid
                    WHERE 
                        (p_creator_tid IS NULL OR lp.creator_tid = p_creator_tid)
                        AND (p_difficulty_level IS NULL OR lp.difficulty_level = p_difficulty_level)
                        AND (p_sponsored IS NULL OR lp.sponsored = p_sponsored)
                    GROUP BY lp.tid
                    ORDER BY lp.created_at DESC
                    LIMIT p_limit OFFSET p_offset
                ) AS sub
            ),
            JSON_ARRAY()
        )
    ) AS data;

    COMMIT;
END $$
DELIMITER ;
