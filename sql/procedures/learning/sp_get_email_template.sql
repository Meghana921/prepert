DROP PROCEDURE IF EXISTS sp_get_email_template;
DELIMITER //

CREATE PROCEDURE sp_get_email_template (
    IN p_template_id BIGINT UNSIGNED
)
sp_block: BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_name VARCHAR(100);
    DECLARE v_subject VARCHAR(255);
    DECLARE v_body TEXT;
    DECLARE custom_error VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'Database error while fetching email template')
        ) AS data;
        RESIGNAL;
    END;

    -- Check if template exists
    SELECT COUNT(*) INTO v_exists
    FROM dt_invite_templates
    WHERE tid = p_template_id;

    IF v_exists = 0 THEN
        SET custom_error = 'Template not found';
        SIGNAL SQLSTATE '45000';
    END IF;

    -- Fetch and return template details
    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', JSON_OBJECT(
            'template_id', p_template_id,
            'name', v_name,
            'subject', v_subject,
            'body', v_body
        )
    ) AS data
    FROM (
        SELECT name, subject, body
        INTO v_name, v_subject, v_body
        FROM dt_invite_templates
        WHERE tid = p_template_id
    ) AS temp;

END //
DELIMITER ;
