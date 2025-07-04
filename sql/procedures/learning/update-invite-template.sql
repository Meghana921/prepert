DROP PROCEDURE IF EXISTS update_invite_template;
DELIMITER $$

CREATE PROCEDURE update_invite_template(
  IN in_template_id   BIGINT,
  IN in_new_name      VARCHAR(100),
  IN in_new_subject   VARCHAR(255),
  IN in_new_body      TEXT
)
BEGIN
  DECLARE template_exists INT DEFAULT 0;
  DECLARE custom_error VARCHAR(255);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error, 'An error occurred while updating the template')AS message;
  END;

  START TRANSACTION;

  -- Check if the template exists and belongs to the creator
  SELECT COUNT(*) INTO template_exists
  FROM dt_invite_templates 
  WHERE tid = in_template_id ;

  IF template_exists = 0 THEN
    SET custom_error = 'Invite template not found or does not belong to the creator';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Perform update
  UPDATE dt_invite_templates
  SET 
    name    = in_new_name,
    subject = in_new_subject,
    body    = in_new_body
  WHERE tid = in_template_id;

  COMMIT;

  -- Success response
  SELECT JSON_OBJECT(
      'template_id', in_template_id,
      'template_name', in_new_name
  ) AS data;
END $$

DELIMITER ;


