-- This procedure retrieves all invite templates created by a specific user (creator) in JSON format.

DROP PROCEDURE IF EXISTS list_invite_template;

DELIMITER //

CREATE PROCEDURE list_invite_template(IN creator_id BIGINT)
BEGIN
    -- Select a structured JSON object containing all invite templates for the given creator
    SELECT 
        JSON_OBJECT(
            "templates", 
            IFNULL(
                JSON_ARRAYAGG( 
                    JSON_OBJECT(
                        "template_tid", tid,        
                        "template_name", name       
                    )
                ),
                JSON_ARRAY() 
            )
        ) AS data; 
    FROM dt_invite_templates
    WHERE creator_tid = creator_id; 
END //

DELIMITER ;
