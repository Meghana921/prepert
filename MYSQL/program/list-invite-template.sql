DROP PROCEDURE IF EXISTS list_invite_template;
DELIMITER $$
CREATE PROCEDURE list_invite_template(IN creator_id BIGINT)
BEGIN
SELECT JSON_OBJECT("templateID",TID,"templateName",name) AS " Templates" FROM dt_invite_templates
WHERE creator_tid = creator_id;
END $$
DELIMITER ;

call list_invite_template(15);