DROP PROCEDURE IF EXISTS add_learning_program;

DELIMITER //

CREATE PROCEDURE add_learning_program (
    IN in_title VARCHAR(100),
    IN in_description TEXT,
    IN in_creator_id BIGINT,
    IN in_difficulty_level VARCHAR(1),  -- Changed to VARCHAR to match ENUM
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
    IN in_invitees JSON
)
BEGIN
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;
    DECLARE learning_program_id BIGINT;
    DECLARE v_program_code VARCHAR(20);
    
    -- Error handler for rollback and exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET custom_error = COALESCE(custom_error, 'An error occurred during program creation');
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END;

    START TRANSACTION;

    -- Prevent duplicate programs with same title and creator
    IF EXISTS (SELECT 1 FROM dt_learning_programs
              WHERE title = in_title AND creator_tid = in_creator_id) THEN
        SET custom_error = 'Program already exists. You can view or modify the existing one.';
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END IF;
    
    -- Generate program code
    SET v_program_code = CONCAT("PR-", DATE_FORMAT(CURRENT_DATE(), '%Y%m%d'), FLOOR(RAND()*2));
    
    -- Validate difficulty level
    IF in_difficulty_level NOT IN ('0', '1', '2', '3') THEN
        SET custom_error = 'Invalid difficulty level. Must be 0, 1, 2, or 3';
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END IF;

    -- Insert program details (FIXED: using correct column/variable names)
    INSERT INTO dt_learning_programs (
        title, program_code, description, creator_tid, difficulty_level,
        image_path, price, access_period_months, available_slots,
        campus_hiring, sponsored, minimum_score,
        experience_from, experience_to, locations,
        employer_name, regret_message,
        eligibility_template_tid, invite_template_tid
    )
    VALUES (
        in_title, v_program_code, in_description, in_creator_id, in_difficulty_level,
        in_image_path, in_price, in_access_period_months, in_available_slots,
        in_campus_hiring, in_sponsored, in_minimum_score,
        in_experience_from, in_experience_to, in_locations,
        in_employer_name, in_regret_message,
        in_eligibility_template_id, in_invite_template_id
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

    -- Insert invitees if provided
    IF JSON_LENGTH(in_invitees) > 0 THEN
        INSERT INTO dt_invitees (learning_program_tid, name, email)
        SELECT
            learning_program_id,
            i.name,
            i.email
        FROM JSON_TABLE (
            in_invitees,
            '$[*]' COLUMNS (
                name VARCHAR(100) PATH '$.name',
                email VARCHAR(255) PATH '$.email'
            )
        ) AS i;
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


CALL add_learning_program(
    'Full Stack Developer Program 2025',  -- in_title
    'An intensive program covering frontend, backend, and deployment.',  -- in_description
    1,  -- in_creator_id (valid user ID)
    '3',  -- in_difficulty_level (TINYINT)
    '/images/fullstack.png',  -- in_image_path
    499.99,  -- in_price
    6,  -- in_access_period_months
    50,  -- in_available_slots
    TRUE,  -- in_campus_hiring
    TRUE,  -- in_sponsored
    70,  -- in_minimum_score
    '0',  -- in_experience_from
    '2',  -- in_experience_to
    'Bangalore,Hyderabad',  -- in_locations
    'TechNova Inc.',  -- in_employer_name
    'Thank you for applying. You may not be eligible at this time.',  -- in_regret_message
    1,  -- in_eligibility_template_id (valid template ID)
    1,  -- in_invite_template_id (valid template ID)
    '[{"name":"Shashi","email":"shashikanthks017@gmail.com"},{"name":"Meghana S","email":"meghana.s921@gmail.com"}]'  -- in_invitees
);

CALL add_learning_program(
    'Full Stack Developer Program 2025',  -- in_title
    'An intensive program covering frontend, backend, and deployment.',  -- in_description
    1,  -- in_creator_id
    '2',  -- in_difficulty_level
    '/images/fullstack.png',  -- in_image_path
    499.99,  -- in_price
    6,  -- in_access_period_months
    50,  -- in_available_slots
    TRUE,  -- in_campus_hiring
    TRUE,  -- in_sponsored
    70,  -- in_minimum_score
    '0',  -- in_experience_from
    '2',  -- in_experience_to
    'Bangalore,Hyderabad',  -- in_locations
    'TechNova Inc.',  -- in_employer_name
    'Thank you for applying. You may not be eligible at this time.',  -- in_regret_message
    1,  -- in_eligibility_template_id
    1,  -- in_invite_template_id
    '[{"name":"Shashi","email":"shashikanthks017@gmail.com"},{"name":"Meghana S","email":"meghana.s921@gmail.com"}]'
);

