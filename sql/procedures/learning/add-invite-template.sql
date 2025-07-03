DROP PROCEDURE IF EXISTS add_invite_template;

DELIMITER $$

CREATE PROCEDURE add_invite_template(
  IN in_creator_tid BIGINT,
  IN in_program_id BIGINT,         -- (Note: This is accepted but not used – you may remove it if not needed)
  IN in_name VARCHAR(100),
  IN in_subject VARCHAR(255),
  IN in_body TEXT
)
BEGIN
  DECLARE custom_error VARCHAR(255) DEFAULT NULL;
  DECLARE new_template_id BIGINT;

  -- Error handler
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT JSON_OBJECT(
      'status', FALSE,
      'message', COALESCE(custom_error, 'An error occurred while inserting template')
    ) AS data;
  END;

  START TRANSACTION;

  -- Check if template already exists
  IF EXISTS (
    SELECT 1
    FROM dt_invite_templates
    WHERE creator_tid = in_creator_tid AND name = in_name
  ) THEN
    SET custom_error = CONCAT(in_name, ' - template already exists! You can view and edit template');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Insert the new invite template
  INSERT INTO dt_invite_templates (
    creator_tid, name, subject, body
  ) VALUES (
    in_creator_tid, in_name, in_subject, in_body
  );

  SET new_template_id = LAST_INSERT_ID();

  COMMIT;

  -- Return success response
  SELECT JSON_OBJECT(
    'status', TRUE,
    'data', JSON_OBJECT(
      'template_id', new_template_id,
      'template_name', in_name
    )
  ) AS data;
END $$

DELIMITER ;
