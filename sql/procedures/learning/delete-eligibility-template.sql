DROP PROCEDURE IF EXISTS deleteEligibilityTemplate;
DELIMITER $$
CREATE PROCEDURE deleteEligibilityTemplate(IN template_id BIGINT)
BEGIN
START TRANSACTION;
DELETE FROM dt_eligibility_templates
WHERE TID = template_id;

DELETE FROM dt_eligibility_questions
WHERE  template_tid = template_id;
COMMIT;
END $$

call deleteEligibilityTemplate(14);