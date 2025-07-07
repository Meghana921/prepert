-- This procedure returns the details of a specific invite template as a JSON object based on the given template ID.

DROP PROCEDURE IF EXISTS view_invite_template;
DELIMITER $$

CREATE PROCEDURE view_invite_template(
  IN in_template_id BIGINT
)
BEGIN
  SELECT JSON_OBJECT(
    'template_tid', tid,
    'template_name', name,
    'subject', subject,
    'body', body
  ) AS data
  FROM dt_invite_templates
  WHERE tid = in_template_id;
END $$

DELIMITER ;
