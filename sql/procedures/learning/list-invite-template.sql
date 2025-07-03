DROP PROCEDURE IF EXISTS list_invite_template;
DELIMITER //

CREATE PROCEDURE list_invite_template(IN creator_id BIGINT)
BEGIN
    SELECT 
        JSON_ARRAYAGG(
            JSON_OBJECT(
                "templateID", tid,
                "templateName", name
            )
        ) AS invitee_templates
    FROM dt_invite_templates
    WHERE creator_tid = creator_id;
END //

DELIMITER ;
