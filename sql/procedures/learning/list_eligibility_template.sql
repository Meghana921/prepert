DROP PROCEDURE IF EXISTS list_eligibility_template;
DELIMITER //

CREATE PROCEDURE list_eligibility_template(IN in_creator_tid BIGINT)
/* Returns all eligibility templates created by a specific user in JSON format */
BEGIN
    -- Return a JSON array of all templates created by the user
    SELECT 
            IFNULL(
                JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'template_tid', t.tid,
                        'template_name', t.name
                    )
                ),
                JSON_ARRAY()  -- Return empty array if no templates exist
        ) AS data
    FROM dt_eligibility_templates t
    WHERE t.creator_tid = in_creator_tid;
END //

DELIMITER ;