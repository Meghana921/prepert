-- Drop the procedure if it already exists to avoid conflicts
DROP PROCEDURE IF EXISTS view_all_learning_program;

DELIMITER $$

-- Create a procedure to fetch all learning programs along with aggregated details
CREATE PROCEDURE view_all_learning_program()
BEGIN

    -- Return all programs as a JSON array 
    SELECT COALESCE(
        (
            SELECT JSON_ARRAYAGG(course_data)  -- Aggregate each program's JSON object into an array
            FROM (
                SELECT JSON_OBJECT(
                    'program_id',        lp.tid,
                    'title',             lp.title,
                    'description',       lp.description,

                    -- Convert difficulty level codes to readable labels
                    'difficulty_level',  CASE 
                                            WHEN lp.difficulty_level = "0" THEN "easy"
                                            WHEN lp.difficulty_level = "1" THEN "medium"
                                            WHEN lp.difficulty_level = "2" THEN "high"
                                            ELSE "very_high"
                                         END,

                    'image_path',        lp.image_path,
                    'price',             lp.price,
                    'access_period_months', lp.access_period_months,
                    'available_slots',   lp.available_slots,
                    'campus_hiring',     lp.campus_hiring,
                    'sponsored',         lp.sponsored,
                    'experience_from',   lp.experience_from,
                    'experience_to',     lp.experience_to,
                    'locations',         lp.locations,

                    -- Count distinct enrollments and modules for each program
                    'enrollment_count',  COUNT(DISTINCT e.tid),
                    'module_count',      COUNT(DISTINCT m.tid)
                ) AS course_data

                -- Join with enrollment and module tables to gather related data
                FROM dt_learning_programs lp
                LEFT JOIN dt_learning_enrollments e ON lp.tid = e.learning_program_tid
                LEFT JOIN dt_learning_modules m     ON lp.tid = m.learning_program_tid

                -- Only include programs that have a creator assigned
                WHERE lp.creator_tid IS NOT NULL

                -- Group by program to aggregate counts correctly
                GROUP BY lp.tid

                -- Order programs by newest first
                ORDER BY lp.created_at DESC
            ) AS sub
        ),
        JSON_ARRAY()  -- Return empty JSON array if no programs exist
    ) AS data;

END $$

DELIMITER ;

-- Call the procedure to fetch all programs
CALL view_all_learning_program();
