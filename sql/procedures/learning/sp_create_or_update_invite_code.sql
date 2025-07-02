DELIMITER $$

CREATE PROCEDURE sp_create_or_update_invite_code(
    IN p_email VARCHAR(255),
    IN p_program_id BIGINT UNSIGNED,
    IN p_code VARCHAR(255)
)
BEGIN
    DECLARE v_existing_id BIGINT DEFAULT NULL;

    -- Check for existing invite with status 'invited' or 'accepted'
    SELECT tid INTO v_existing_id
    FROM dt_invitees
    WHERE email COLLATE utf8mb4_0900_ai_ci = p_email COLLATE utf8mb4_0900_ai_ci
      AND learning_program_tid = p_program_id
      AND status IN ('invited', 'accepted')
    LIMIT 1;

    IF v_existing_id IS NOT NULL THEN
        -- Update the code and timestamp
        UPDATE dt_invitees
        SET invite_code = p_code,
            invite_sent_at = NOW(),
            status = 'invited'
        WHERE tid = v_existing_id;
    ELSE
        -- Insert new invite
        INSERT INTO dt_invitees (learning_program_tid, name, email, invite_code, status, invite_sent_at)
        VALUES (p_program_id, '', p_email, p_code, 'invited', NOW());
    END IF;
END$$

DELIMITER ;
