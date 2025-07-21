DELIMITER //

-- Updates sponsorship details for a learning program (slots & cancellation status)
CREATE PROCEDURE update_sponsored_program(
    IN in_program_id BIGINT,     -- ID of the learning program
    IN in_slots INT,             -- Number of sponsored seats to allocate
    IN in_cancelled BOOLEAN      -- Flag to indicate whether sponsorship is cancelled
)
BEGIN
    START TRANSACTION;

    -- Update sponsored seat allocation and cancellation status
    UPDATE dt_program_sponsorships 
    SET 
        seats_allocated = in_slots,
        is_cancelled = in_cancelled
    WHERE learning_program_tid = in_program_id;

    COMMIT;
END //

DELIMITER ;
