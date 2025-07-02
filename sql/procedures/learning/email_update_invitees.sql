DELIMITER $$

CREATE PROCEDURE email_update_invitees(
    IN p_learning_program_tid BIGINT UNSIGNED,
    IN p_email                VARCHAR(255)
)
SP_BLOCK : BEGIN
    DECLARE v_exists INT DEFAULT 0;

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Database error during update' AS message, 500 AS status_code;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Check if the invitee exists
    SELECT COUNT(*) INTO v_exists
    FROM dt_invitees
    WHERE learning_program_tid = p_learning_program_tid
      AND email = p_email;

    IF v_exists = 0 THEN
        ROLLBACK;
        SELECT 'Invitee not found' AS message, 404 AS status_code;
        LEAVE SP_BLOCK;
    END IF;

    -- Perform the update
    UPDATE dt_invitees 
    SET 
        status = 'invited',
        invite_timestamp = NOW()
    WHERE 
        learning_program_tid = p_learning_program_tid
        AND email = p_email;

    COMMIT;

    -- Return success response
    SELECT 'Invitee status updated successfully' AS message, 200 AS status_code;
END $$

DELIMITER ;
