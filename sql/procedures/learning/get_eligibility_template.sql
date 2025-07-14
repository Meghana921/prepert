DROP PROCEDURE IF EXISTS get_eligibility_template;
DELIMITER //
CREATE PROCEDURE get_eligibility_template(
    IN in_program_id BIGINT
)
BEGIN
    DECLARE in_template_tid BIGINT;
    DECLARE custom_error VARCHAR(255);
    DECLARE available_slots INT DEFAULT NULL;
    DECLARE error_message VARCHAR(255);
    DECLARE current_enrollments INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        ROLLBACK;
        SET custom_error = COALESCE(error_message, 'Unknown error occurred.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END;

    START TRANSACTION;

    -- Get number of allocated seats, if any
    SELECT seats_allocated 
    INTO available_slots
    FROM dt_program_sponsorships 
    WHERE learning_program_tid = in_program_id
    LIMIT 1;

    IF available_slots IS NOT NULL THEN
        -- If sponsored, check current enrollments
        SELECT COUNT(*) 
        INTO current_enrollments
        FROM dt_learning_enrollments 
        WHERE learning_program_tid = in_program_id;

        IF current_enrollments >= available_slots THEN
            SET custom_error = 'No sponsored slots available in this program';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
        END IF;
    END IF;

    -- Fetch template ID regardless of sponsorship
    SELECT eligibility_template_tid 
    INTO in_template_tid 
    FROM dt_learning_programs
    WHERE tid = in_program_id;

    -- Call procedure to return template
    CALL view_eligibility_template(in_template_tid);

    COMMIT;
END //
DELIMITER ;