DROP PROCEDURE IF EXISTS update_invitee_email_status;
DELIMITER //

-- Updates email delivery status for an invitee
CREATE PROCEDURE update_invitee_email_status (
    IN in_invite_id BIGINT UNSIGNED,
    IN in_email_status ENUM('1', '2')   -- 1:sent, 2:failed
)
BEGIN
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;
    DECLARE error_message VARCHAR(255);
    
    -- Handle SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN 
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        SET custom_error = COALESCE(custom_error, error_message);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END;

    START TRANSACTION;

    -- Update invitee's email status
    UPDATE dt_invitees
    SET
        email_status = in_email_status,  -- Set delivery status
        status = "0"                     -- Reset invite status
    WHERE
        tid = in_invite_id;           

    -- Verify update was successful
    IF ROW_COUNT() = 0 THEN
        SET custom_error = 'No matching invitee found';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;

    COMMIT;
END//

DELIMITER ;