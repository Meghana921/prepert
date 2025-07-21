-- This procedure retrieves all invite templates created by a specific creator in JSON format.
DROP PROCEDURE IF EXISTS list_invite_template;
DELIMITER //

CREATE PROCEDURE list_invite_template(IN creator_id BIGINT)
BEGIN
    -- Returns JSON array of templates 
    SELECT 
            IFNULL(
                JSON_ARRAYAGG( 
                    JSON_OBJECT(
                        "template_tid", tid,        -- Template ID
                        "template_name", name       -- Template name
                    )
                ),
                JSON_ARRAY()  -- Return empty array when no templates exist
            ) AS data
    FROM dt_invite_templates
    WHERE creator_tid = creator_id; 
END //
DELIMITER ;