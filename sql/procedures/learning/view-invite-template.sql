DROP PROCEDURE IF EXISTS view_invite_template;

DELIMITER $$
CREATE PROCEDURE view_invite_template(
  IN in_template_id BIGINT
)
BEGIN
  DECLARE custom_error VARCHAR(255);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT  COALESCE(custom_error, 'Failed to retrieve template')AS message;
  END;

  START TRANSACTION;
  IF NOT EXISTS (SELECT 1 FROM dt_invite_templates WHERE tid = in_template_id) THEN
   SET custom_error = CONCAT('Template not found (ID: ', in_template_id, ')');
    SIGNAL SQLSTATE '45000' ;
 END IF;
    SELECT 
       JSON_OBJECT(
          'id', tid,
          'name', name,
          'subject', subject,
          'body', body
      ) AS body
    FROM dt_invite_templates
    WHERE tid = in_template_id;
COMMIT;
END $$
DELIMITER ;

CALL view_invite_template(1);