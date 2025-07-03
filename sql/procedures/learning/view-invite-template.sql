DROP PROCEDURE IF EXISTS view_invite_template;
DELIMITER $$

CREATE PROCEDURE view_invite_template(
  IN in_template_id BIGINT
)
BEGIN
  DECLARE custom_error VARCHAR(255);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT JSON_OBJECT(
      'status', FALSE,
      'message', COALESCE(custom_error, 'Failed to retrieve template')
    ) AS data;
  END;

  -- Check if template exists
  IF NOT EXISTS (
    SELECT 1 FROM dt_invite_templates WHERE tid = in_template_id
  ) THEN
    SET custom_error = CONCAT('Template not found (ID: ', in_template_id, ')');
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Return template as JSON
  SELECT JSON_OBJECT(
    'status', TRUE,
    'data', JSON_OBJECT(
        'id', tid,
        'name', name,
        'subject', subject,
        'body', body
    )
  ) AS data
  FROM dt_invite_templates
  WHERE tid = in_template_id;
END $$

DELIMITER ;

-- CALL view_invite_template(1);
-- {
--   "status": true,
--   "data": {
--     "template_id": 1,
--     "template_name": "Sample Template",
--     "questions": [
--       {
--         "question": "Are you a graduate?",
--         "deciding_answer": "yes",
--         "sequence_number": 1
--       },
--       ...
--     ]
--   }
-- }
