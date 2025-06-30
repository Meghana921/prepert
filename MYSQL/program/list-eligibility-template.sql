DROP PROCEDURE IF EXISTS list_eligibility_template;
DELIMITER $$
CREATE PROCEDURE list_eligibility_template(IN creator_id BIGINT)
BEGIN
SELECT JSON_OBJECT("templateID",TID,"templateName",name) AS "Eligibility Templates" FROM dt_eligibility_templates
WHERE creator_tid = creator_id;
END $$
DELIMITER ;

call list_eligibility_template(15);