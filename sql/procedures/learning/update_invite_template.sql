DROP PROCEDURE IF EXISTS update_invite_template;
DELIMITER $$

-- Updates an existing invitation template with new details
CREATE PROCEDURE update_invite_template(
  IN in_template_id   BIGINT,
  IN in_new_name      VARCHAR(100),
  IN in_new_subject   VARCHAR(255),
  IN in_new_body      TEXT
)
BEGIN
  DECLARE custom_error VARCHAR(255);
DECLARE error_message VARCHAR(255);
    -- Error handler for transaction rollback on failure
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
    error_message= MESSAGE_TEXT;
    ROLLBACK;
    SET custom_error = COALESCE(custom_error,error_message);
    SIGNAL SQLSTATE '45000'
    
        SET MESSAGE_TEXT = custom_error;
END;
  START TRANSACTION;

  -- Verify template exists before attempting update
  IF NOT EXISTS (SELECT 1
  FROM dt_invite_templates 
  WHERE tid = in_template_id ) THEN
    SET custom_error = 'Invite template not found!';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Update template fields with new values
  UPDATE dt_invite_templates
  SET 
    name    = in_new_name,
    subject = in_new_subject,
    body    = in_new_body
  WHERE tid = in_template_id;
  
  -- Prevent duplicate template names for same creator
  IF EXISTS (SELECT count(tid) as cnt from dt_invite_templates
  WHERE name = in_new_name
  GROUP BY creator_tid
  having cnt > 1) THEN
  SET custom_error = "Please choose a different name — this template already exists";
  SIGNAL SQLSTATE "45000";
  END IF;
  
  COMMIT;

  -- Return updated template information
  SELECT JSON_OBJECT(
      'template_id', in_template_id,
      'template_name', in_new_name
  ) AS data;
END $$

DELIMITER ;