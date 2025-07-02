DELIMITER $$

CREATE PROCEDURE sp_validate_invite_code(
    IN p_code VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_program_id BIGINT UNSIGNED
)
BEGIN
    -- Returns 1 row if valid, 0 rows if not
    SELECT tid
    FROM dt_invitees
    WHERE invite_code = p_code
      AND email = p_email
      AND learning_program_tid = p_program_id
      AND status = 'invited'
    LIMIT 1;
END$$

DELIMITER ; 