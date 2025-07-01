DROP PROCEDURE IF EXISTS add_invite_template;

DELIMITER $$
CREATE PROCEDURE add_invite_template(
  IN in_creator_tid BIGINT,
  IN in_program_id BIGINT,
  IN in_name VARCHAR(100),
  IN in_subject VARCHAR(255),
  IN in_body TEXT
)
BEGIN
  DECLARE custom_error VARCHAR(255);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error, "An error occurred while inserting template") as message;
  END;

  START TRANSACTION;
  
  -- Check if template already exists using EXISTS
  IF EXISTS (
    SELECT 1 FROM dt_invite_templates
    WHERE creator_tid = in_creator_tid AND program_i = in_name
  ) THEN 
    SET custom_error = CONCAT(in_name, ' - template already exists! You can view and edit template');
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Insert new template
  INSERT INTO dt_invite_templates(creator_tid, name, subject, body) 
  VALUES (in_creator_tid, in_name, in_subject, in_body);
  
  SELECT 
    JSON_OBJECT(
      "template_id", LAST_INSERT_ID(),
      "template_name", in_name
    ) AS data;
  
  COMMIT;
END $$
DELIMITER ;

-- First call (should succeed)
CALL add_invite_template(
  1,                          -- creator_tid
  'Summer Internship 2024',       -- template name
  'Join Our Summer Internship!',  -- subject
  'Dear {name},\n\nWe are excited to invite you...'  -- body
);