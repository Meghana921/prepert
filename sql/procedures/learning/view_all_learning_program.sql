DROP PROCEDURE IF EXISTS view_all_learning_program;

DELIMITER $$

CREATE PROCEDURE view_all_learning_program()
BEGIN

    SELECT COALESCE(
        (
            SELECT JSON_ARRAYAGG(course_data)
            FROM (
                SELECT JSON_OBJECT(
                    'program_id',        lp.tid,
                    'title',             lp.title,
                    'description',       lp.description,

                    'difficulty_level',  CASE 
                                            WHEN lp.difficulty_level = '0' THEN 'easy'
                                            WHEN lp.difficulty_level = '1' THEN 'medium'
                                            WHEN lp.difficulty_level = '2' THEN 'high'
                                            ELSE 'very_high'
                                         END,

                    'image_path',        lp.image_path,
                    'price',             lp.price,
                    'access_period_months', lp.access_period_months,

                    -- Use aggregate wrappers to satisfy ONLY_FULL_GROUP_BY
                    'available_slots',   MAX(ps.seats_allocated - ps.seats_used),
                    'sponsored',         MAX(IF(ps.tid IS NOT NULL AND ps.is_cancelled = 0, TRUE, FALSE)),

                    'campus_hiring',     lp.campus_hiring,
                    'experience_from',   lp.experience_from,
                    'experience_to',     lp.experience_to,
                    'locations',         lp.locations,

                    'enrollment_count',  COUNT(DISTINCT e.tid),
                    'module_count',      COUNT(DISTINCT m.tid)
                ) AS course_data

                FROM dt_learning_programs lp
                LEFT JOIN dt_program_sponsorships ps ON lp.tid = ps.learning_program_tid
                LEFT JOIN dt_learning_enrollments e ON lp.tid = e.learning_program_tid
                LEFT JOIN dt_learning_modules m     ON lp.tid = m.learning_program_tid

                WHERE lp.creator_tid IS NOT NULL AND lp.is_public IS TRUE

                GROUP BY lp.tid

                ORDER BY lp.created_at DESC
            ) AS sub
        ),
        JSON_ARRAY()
    ) AS data;

END $$

DELIMITER ;
