DROP PROCEDURE IF EXISTS get_email_template;
DELIMITER //

CREATE PROCEDURE get_email_template(
    IN in_invite_template_id BIGINT
)
BEGIN
    DECLARE v_template_content TEXT;
    DECLARE v_template_name VARCHAR(255);
    DECLARE v_exists INT DEFAULT 0;

    -- Check if the template exists
    SELECT COUNT(*) INTO v_exists
    FROM dt_invite_templates
    WHERE tid = in_invite_template_id;

    IF v_exists = 0 THEN
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', 'Invite template not found'
        ) AS data;
    ELSE
        -- Fetch the content and name
        SELECT content, name
        INTO v_template_content, v_template_name
        FROM dt_invite_templates
        WHERE tid = in_invite_template_id
        LIMIT 1;

        SELECT JSON_OBJECT(
            'status', TRUE,
            'template_content', v_template_content,
            'template_name', v_template_name
        ) AS data;
    END IF;
END //

DELIMITER ;
