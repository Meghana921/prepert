DROP PROCEDURE IF EXISTS add_invite_template;
DELIMITER //

/* Creates a new email invitation template for program invitations */
CREATE PROCEDURE add_invite_template (
  IN in_creator_tid BIGINT,
  IN in_name VARCHAR(100),
  IN in_subject VARCHAR(255),
  IN in_body TEXT
) 
BEGIN 
  DECLARE custom_error VARCHAR(255) DEFAULT NULL;
  DECLARE error_message VARCHAR(255);

  -- Error handler to rollback on any SQL exception
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN 
    ROLLBACK;
    GET DIAGNOSTICS CONDITION 1 
    error_message = MESSAGE_TEXT;
    SET custom_error = COALESCE(custom_error, error_message);
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = custom_error;
  END;

  -- Begin transaction
  START TRANSACTION;

  -- Validate template name uniqueness for this creator
  IF EXISTS (
    SELECT 1
    FROM dt_invite_templates
    WHERE creator_tid = in_creator_tid
      AND name = in_name
  ) THEN
    SET custom_error = 'An entry with the given template name already exists. Please use a different name or update the existing one.';
    SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Create new template record
  INSERT INTO dt_invite_templates (
    creator_tid, 
    name, 
    subject, 
    body
  )
  VALUES (
    in_creator_tid, 
    in_name, 
    in_subject, 
    in_body
  );

  COMMIT;

  -- Return new template details
  SELECT JSON_OBJECT(
    'template_id', LAST_INSERT_ID(),
    'template_name', in_name
  ) AS data;
END //
DELIMITER ;