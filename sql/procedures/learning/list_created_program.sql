DROP PROCEDURE IF EXISTS list_created_program;
DELIMITER //

CREATE PROCEDURE list_created_program(IN creator_id BIGINT)
BEGIN
    -- This procedure returns all programs created by a given creator as a JSON array.
    SELECT COALESCE(
            (
                -- Aggregate all learning programs created by the given creator
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'program_id', lp.tid,       -- Program ID
                        'program_name', lp.title    -- Program Name
                    )
                )
                FROM dt_learning_programs lp
                WHERE lp.creator_tid = creator_id  -- Filter by creator ID
                ORDER BY lp.created_at             -- Order by creation date
            ),
            JSON_ARRAY() -- Return empty array if no programs found
        
    ) AS data;
END //
DELIMITER ;
