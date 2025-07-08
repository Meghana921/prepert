DROP PROCEDURE IF EXISTS update_invitee_email_status;
DELIMITER $$

CREATE PROCEDURE update_invitee_email_status (
    IN in_learning_program_tid BIGINT UNSIGNED,
    IN in_email VARCHAR(255),
    IN in_email_status ENUM('1', '2')  -- 1: sent, 2: failed
)
BEGIN
    UPDATE dt_invitees
    SET
        email_status = in_email_status,
        invite_sent_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE
        learning_program_tid = in_learning_program_tid
        AND email = in_email;
END$$

DELIMITER ;
