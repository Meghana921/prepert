DROP PROCEDURE IF EXISTS update_invite_template;
DELIMITER $$

CREATE PROCEDURE update_invite_template(
  IN in_template_id   BIGINT,
  IN in_new_name      VARCHAR(100),
  IN in_new_subject   VARCHAR(255),
  IN in_new_body      TEXT
)
BEGIN
  DECLARE custom_error VARCHAR(255);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error, 'An error occurred while updating the template')AS message;
  END;

  START TRANSACTION;

  -- Check if the template exists and belongs to the creator
  IF NOT EXISTS (SELECT 1
  FROM dt_invite_templates 
  WHERE tid = in_template_id ) THEN
    SET custom_error = 'Invite template not found!';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Perform update
  UPDATE dt_invite_templates
  SET 
    name    = in_new_name,
    subject = in_new_subject,
    body    = in_new_body
  WHERE tid = in_template_id;
  
  -- Checking if templete is renamed as existing template
  IF EXISTS (SELECT count(tid) as cnt from dt_invite_templates
  WHERE name = in_new_name
  GROUP BY creator_tid
  having cnt > 1) THEN
  SET custom_error = "Please choose a different name — this template already exists";
  SIGNAL SQLSTATE "45000";
  END IF;
  COMMIT;

  -- Success response
  SELECT JSON_OBJECT(
      'template_id', in_template_id,
      'template_name', in_new_name
  ) AS data;
END $$

DELIMITER ;

 
