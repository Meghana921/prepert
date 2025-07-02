DROP PROCEDURE IF EXISTS update_invite_template;

DELIMITER $$
CREATE PROCEDURE update_invite_template(
  IN in_creator_tid BIGINT,
  IN in_template_id BIGINT,
  IN in_new_name VARCHAR(100),
  IN in_new_subject VARCHAR(255),
  IN in_new_body TEXT
)
BEGIN
  DECLARE template_tid BIGINT;
  DECLARE custom_error VARCHAR(255);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error, "An error occurred while updating template") as message;
  END;

  START TRANSACTION;
  
  SELECT tid INTO template_tid 
  FROM dt_invite_templates 
  WHERE creator_tid = in_creator_tid 
  AND tid= in_template_id
  LIMIT 1;
  
  IF template_tid IS NULL THEN
    SET custom_error = CONCAT('Template not found ');
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Update template
  UPDATE dt_invite_templates
  SET 
  name =in_new_name,
    subject = in_new_subject,
    body = in_new_body
  WHERE tid = template_tid;

  -- Return success response
  SELECT 
    JSON_OBJECT(
      "template_id", template_tid,
      "template_name", in_new_name
    ) AS data;
  
  COMMIT;
END $$
DELIMITER ;

CALL update_invite_template(
  12345,   
  2,-- creator_tid
  'Summer Internship 2024',       -- template name
  'Join Our Summer Internship!',  -- subject
  'Dear {name},\n\nWe are excited to invite you...'  -- body
);