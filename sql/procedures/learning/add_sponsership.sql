DROP PROCEDURE IF EXISTS add_sponsorship;
DELIMITER //

CREATE PROCEDURE add_sponsorship(
    IN in_program_id   BIGINT,   -- ID of the learning program
    IN in_creator_id   BIGINT,   -- ID of the creator (company user)
    IN in_slots        INT       -- Number of allocated seats
)
BEGIN
    -- Variable declarations
    DECLARE custom_error VARCHAR(255);
    DECLARE error_message VARCHAR(255);
    
    -- Error handler to ensure rollback and return a clear error message
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        SET custom_error = COALESCE(custom_error, error_message);
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
    END;

    -- Start transaction to ensure atomicity
    START TRANSACTION;

    -- Validate that the program exists and the creator has access to it
    IF NOT EXISTS (
        SELECT 1 
        FROM dt_learning_programs 
        WHERE creator_tid = in_creator_id AND tid = in_program_id
    ) THEN 
        SET custom_error = "Program not found or you do not have access to add sponsorship!";
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END IF;

    -- Check if sponsorship already exists for the program
    IF EXISTS (
        SELECT 1 
        FROM dt_program_sponsorships
        WHERE learning_program_tid = in_program_id
    ) THEN 
        SET custom_error = "Sponsorship already exists for this program!";
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END IF;

    -- Insert sponsorship details
    INSERT INTO dt_program_sponsorships (
        company_user_tid,
        learning_program_tid,
        seats_allocated
    ) VALUES (
        in_creator_id,
        in_program_id,
        in_slots
    );

    -- Commit transaction upon successful insert
    COMMIT;

END //

DELIMITER ;
