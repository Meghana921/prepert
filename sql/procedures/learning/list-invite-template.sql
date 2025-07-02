DROP PROCEDURE IF EXISTS list_eligibility_template;
DELIMITER //
CREATE PROCEDURE list_eligibility_template(IN creator_id BIGINT)
BEGIN
SELECT JSON_OBJECT("templateID",tid,"templateName",name) AS eligibility_templates FROM dt_eligibility_templates
WHERE creator_tid = creator_id;
END //
DELIMITER ;

