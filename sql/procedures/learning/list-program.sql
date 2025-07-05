DROP PROCEDURE IF EXISTS view_created_program;
DELIMITER //

CREATE PROCEDURE view_created_program(IN creator_id BIGINT)
BEGIN
    DECLARE custom_error VARCHAR(255);

    -- Error handling block
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT  COALESCE(custom_error, 'An error occurred while fetching programs') AS message;
    END;

    -- Main data response
    SELECT JSON_OBJECT(
        "programs",COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'program_id', lp.tid,
                        'program_name', lp.title
                    )
                )
                FROM dt_learning_programs lp
                WHERE lp.creator_tid = creator_id
                ORDER BY lp.created_at
            ),
            JSON_ARRAY()
        )
    ) AS data;
END //
DELIMITER ;
