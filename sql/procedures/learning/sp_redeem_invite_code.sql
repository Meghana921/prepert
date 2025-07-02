DELIMITER $$

CREATE PROCEDURE sp_redeem_invite_code(
    IN p_code VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_program_id BIGINT UNSIGNED,
    IN p_user_id BIGINT UNSIGNED
)
BEGIN
    DECLARE v_invitee_id BIGINT DEFAULT NULL;
    DECLARE v_enrollment_id BIGINT DEFAULT NULL;

    -- Find the invitee
    SELECT tid INTO v_invitee_id
    FROM dt_invitees
    WHERE invite_code COLLATE utf8mb4_0900_ai_ci = p_code COLLATE utf8mb4_0900_ai_ci
      AND email COLLATE utf8mb4_0900_ai_ci = p_email COLLATE utf8mb4_0900_ai_ci
      AND learning_program_tid = p_program_id
      AND status COLLATE utf8mb4_0900_ai_ci = 'invited'
    LIMIT 1;

    IF v_invitee_id IS NOT NULL THEN
        -- Create enrollment
        INSERT INTO dt_learning_enrollments (user_tid, learning_program_tid, status, enrollment_date)
        VALUES (p_user_id, p_program_id, 'enrolled', NOW());

        SET v_enrollment_id = LAST_INSERT_ID();

        -- Update invite status
        UPDATE dt_invitees
        SET status = 'accepted',
            response_at = NOW(),
            enrollment_tid = v_enrollment_id
        WHERE tid = v_invitee_id;
    END IF;
END$$

DELIMITER ;

select * from dt_invitees;