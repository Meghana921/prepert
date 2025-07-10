-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS add_invitee;

DELIMITER //

-- Create a procedure to insert a new invitee 
CREATE PROCEDURE add_invitee(
    IN in_program_type ENUM("1","2","3"),
    IN in_program_tid BIGINT,
    IN in_name VARCHAR(100),
    IN in_email VARCHAR(254)
)
BEGIN
    DECLARE invitee_id BIGINT UNSIGNED;
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;
    DECLARE error_message VARCHAR(255);
    -- Error handler for rollback and exception
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
GET DIAGNOSTICS CONDITION 1 
error_message = MESSAGE_TEXT;
SET custom_error = COALESCE(custom_error, error_message);
SIGNAL SQLSTATE '45000'
SET
  MESSAGE_TEXT = custom_error;
END;
    -- Start the transaction
START TRANSACTION;
-- CHECKS if invite already sent
IF EXISTS (SELECT 1 FROM dt_invitees
    WHERE program_type=in_program_type AND program_tid=in_program_tid AND email=in_email AND status = "1")
    THEN 
    SET custom_error = "User already enrolled!";
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    ELSE
    -- Insert the invitee into the invitees table
    INSERT INTO dt_invitees (
        program_type,
        program_tid,
        name,
        email
    ) VALUES (
        in_program_type,
        in_program_tid,
        in_name,
        in_email
    );
    SET invitee_id = LAST_INSERT_ID();
END IF;
    -- Commit the transaction
    COMMIT;
    IF in_program_type = "1" THEN 
    SELECT json_object("invitee_tid",invitee_id,
					    "program_id",lp.tid,
                        "program_title",lp.title,
                        "program_code",lp.program_code,
                        "subject",it.subject,
                        "body",it.body
                        ) as data
		  FROM dt_learning_programs lp
          JOIN dt_invite_templates it ON lp.invite_template_tid = it.tid
          WHERE lp.tid = in_program_tid;
    END IF;
END //

DELIMITER ;
