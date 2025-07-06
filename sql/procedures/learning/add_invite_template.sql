DROP PROCEDURE IF EXISTS add_invite_template;

DELIMITER $$
-- Procedure to create invite template
CREATE PROCEDURE add_invite_template(
  IN in_creator_tid BIGINT,   
  IN in_name VARCHAR(100),
  IN in_subject VARCHAR(255),
  IN in_body TEXT
)
BEGIN
  DECLARE custom_error VARCHAR(255) DEFAULT NULL;

  -- Error handler: Rollback and raise an exception with a message
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET custom_error = COALESCE(custom_error, 'An error occurred while inserting template');
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
  END;

  -- Begin transaction
  START TRANSACTION;

  -- Check if a template with the same name already exists for the same creator
  IF EXISTS (
    SELECT 1
    FROM dt_invite_templates
    WHERE creator_tid = in_creator_tid AND name = in_name
  ) THEN
    SET custom_error = 'An entry with the given template name already exists. Please use a different name or update the existing one.';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error; 
  END IF;

  -- Insert new invite template if validation passes
  INSERT INTO dt_invite_templates (
    creator_tid, name, subject, body
  ) VALUES (
    in_creator_tid, in_name, in_subject, in_body
  );

  COMMIT;

  -- Return newly inserted template ID and name as JSON
  SELECT JSON_OBJECT(
      'template_id', LAST_INSERT_ID(),
      'template_name', in_name
  ) AS data;
END $$

DELIMITER ;
