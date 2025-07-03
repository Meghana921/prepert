DROP PROCEDURE IF EXISTS update_invite_template;
DELIMITER $$

CREATE PROCEDURE update_invite_template(
  IN in_creator_tid   BIGINT,
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
    SELECT JSON_OBJECT(
      'status', FALSE,
      'message', COALESCE(custom_error, 'An error occurred while updating the template')
    ) AS data;
    RESIGNAL;
  END;

  START TRANSACTION;

  -- Check if the template exists and belongs to the creator
  SELECT COUNT(*) INTO template_exists
  FROM dt_invite_templates 
  WHERE tid = in_template_id AND creator_tid = in_creator_tid;

  IF template_exists = 0 THEN
    SET custom_error = 'Invite template not found or does not belong to the creator';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Perform update
  UPDATE dt_invite_templates
  SET 
    name    = in_new_name,
    subject = in_new_subject,
    body    = in_new_body,
    updated_at = NOW()
  WHERE tid = in_template_id;

  COMMIT;

  -- Success response
  SELECT JSON_OBJECT(
    'status', TRUE,
    'data', JSON_OBJECT(
      'template_id', in_template_id,
      'template_name', in_new_name
    )
  ) AS data;
END $$

DELIMITER ;

CALL update_invite_template(
  12345,                     -- creator_tid
  2,                         -- template_id
  'Summer Internship 2024',  -- new name
  'Join Our Summer Internship!',  -- new subject
  'Dear {name},\n\nWe are excited to invite you...'  -- new body
);
