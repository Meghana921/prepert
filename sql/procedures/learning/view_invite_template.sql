-- This procedure returns the details of a specific invite template as a JSON object based on the given template ID.
DROP PROCEDURE IF EXISTS view_invite_template;
DELIMITER $$

CREATE PROCEDURE view_invite_template(
  IN in_template_id BIGINT  -- ID of the template to retrieve
)
BEGIN
  -- Return template details as a formatted JSON object
  SELECT JSON_OBJECT(
    'template_tid', tid,      -- Template ID
    'template_name', name,    -- Template title
    'subject', subject,       -- Email subject line
    'body', body              -- Email body content
  ) AS data
  FROM dt_invite_templates
  WHERE tid = in_template_id; -- Filter by specified template ID
END $$

DELIMITER ;