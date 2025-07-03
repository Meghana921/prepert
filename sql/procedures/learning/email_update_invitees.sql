DELIMITER $$

CREATE PROCEDURE email_update_invitees(
    IN p_learning_program_tid BIGINT UNSIGNED,
    IN p_email                VARCHAR(255)
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255);

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'Database error occurred during invitee update')
        ) AS data;
    END;

    START TRANSACTION;

    -- Check if invitee exists
    SELECT COUNT(*) INTO v_exists
    FROM dt_invitees
    WHERE learning_program_tid = p_learning_program_tid
      AND email = p_email;

    IF v_exists = 0 THEN
        SET custom_error = 'Invitee not found for given program';
        SIGNAL SQLSTATE '45000';
    END IF;

    -- Update status
    UPDATE dt_invitees 
    SET 
        status = 'invited',
        invite_timestamp = NOW()
    WHERE 
        learning_program_tid = p_learning_program_tid
        AND email = p_email;

    COMMIT;

    -- Success response
    SELECT JSON_OBJECT(
        'status', TRUE,
        'message', 'Invitee status updated successfully'
    ) AS data;

END $$

DELIMITER ;
