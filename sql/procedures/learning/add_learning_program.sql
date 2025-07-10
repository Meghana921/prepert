DROP PROCEDURE IF EXISTS add_learning_program;

DELIMITER //

CREATE PROCEDURE add_learning_program (
    IN in_title VARCHAR(100),
    IN in_description TEXT,
    IN in_creator_id BIGINT,
    IN in_difficulty_level VARCHAR(10),  
    IN in_image_path VARCHAR(255),
    IN in_price DECIMAL(10, 2),
    IN in_access_period_months INT,
    IN in_available_slots INT,
    IN in_campus_hiring BOOLEAN,
    IN in_sponsored BOOLEAN,
    IN in_minimum_score TINYINT,
    IN in_experience_from VARCHAR(10),
    IN in_experience_to VARCHAR(10),
    IN in_locations VARCHAR(255),
    IN in_employer_name VARCHAR(100),
    IN in_regret_message TEXT,
    IN in_eligibility_template_id BIGINT,
    IN in_invite_template_id BIGINT,
    IN in_public BOOLEAN
)
BEGIN
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;
    DECLARE learning_program_id BIGINT;
    DECLARE v_program_code VARCHAR(20);
    DECLARE error_message VARCHAR(255);
    -- Error handler for rollback and exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		GET DIAGNOSTICS CONDITION 1
		error_message= MESSAGE_TEXT;
		SET custom_error = COALESCE(custom_error,error_message);
		SIGNAL SQLSTATE '45000'
		
			SET MESSAGE_TEXT = custom_error;
	END;

    START TRANSACTION;

    -- Prevent duplicate programs with same title and creator
    IF EXISTS (SELECT 1 FROM dt_learning_programs
              WHERE title = in_title AND creator_tid = in_creator_id) THEN
        SET custom_error = 'Program already exists. You can view or modify the existing one.';
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END IF;
    
    -- Generate program code
    SELECT CONCAT("PR",LPAD(COALESCE(MAX(SUBSTRING(program_code,3)),0)+1,6,"0" ) ) INTO
    v_program_code FROM dt_learning_programs;
    
    -- Insert program details 
    INSERT INTO dt_learning_programs (
        title,program_code, description, creator_tid, difficulty_level,
        image_path, price, access_period_months, available_slots,
        campus_hiring, sponsored, minimum_score,
        experience_from, experience_to, locations,
        employer_name, regret_message,
        eligibility_template_tid, invite_template_tid,is_public
    )
    VALUES (
        in_title,v_program_code ,in_description, in_creator_id,
        CASE WHEN in_difficulty_level = 'easy' THEN '0'
        WHEN in_difficulty_level = 'medium' THEN '1'
        WHEN in_difficulty_level = 'high' THEN '2'
        ELSE '3'
        END,
        in_image_path, in_price, in_access_period_months, in_available_slots,
        in_campus_hiring, in_sponsored, in_minimum_score,
        in_experience_from, in_experience_to, in_locations,
        in_employer_name, in_regret_message,
        in_eligibility_template_id, in_invite_template_id,in_public
    );

    SET learning_program_id = LAST_INSERT_ID();

    -- Add sponsorship details if applicable
    IF (in_sponsored) THEN
        INSERT INTO dt_program_sponsorships (
            company_user_tid,
            learning_program_tid,
            seats_allocated
        ) VALUES (
            in_creator_id,
            learning_program_id,
            in_available_slots
        );
    END IF;
	COMMIT;
    -- Return success response
    SELECT JSON_OBJECT(
        'program_id', learning_program_id,
        'program_name', in_title,
        'program_code', v_program_code
    ) AS data;
END //

DELIMITER ;