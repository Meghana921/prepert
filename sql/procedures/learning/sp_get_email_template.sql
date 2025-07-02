DELIMITER //

CREATE PROCEDURE sp_get_email_template (
    IN p_template_id BIGINT UNSIGNED
)
sp_block: BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- Exit handler for SQL errors
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Database error while fetching email template' AS message, 500 AS status_code;
        RESIGNAL;
    END;

    -- Optional: Check if template exists
    SELECT COUNT(*) INTO v_exists
    FROM dt_invite_templated
    WHERE tid = p_template_id;

    IF v_exists = 0 THEN
        SELECT 'Template not found' AS message, 404 AS status_code;
        LEAVE sp_block;
    END IF;

    -- Return template body
    SELECT body
    FROM dt_invite_templated
    WHERE tid = p_template_id;

END //

DELIMITER ;
