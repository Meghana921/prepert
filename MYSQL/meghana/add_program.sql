DROP PROCEDURE IF EXISTS add_learning_program;

DELIMITER //
CREATE PROCEDURE add_learning_program (
    IN in_title VARCHAR(100),
    IN in_description TEXT,
    IN in_creator_id BIGINT,
    IN in_difficulty_level ENUM ('low', 'medium', 'high', 'very_high'),
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
) BEGIN DECLARE custom_error VARCHAR(255);

DECLARE learning_program_id BIGINT;

DECLARE existing_tid BIGINT;

DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;

SELECT
    JSON_OBJECT (
        'error',
        COALESCE(
            custom_error,
            'An error occurred during program creation'
        )
    ) AS result;

END;

START TRANSACTION;

SELECT
    tid INTO existing_tid
FROM
    dt_learning_programs
WHERE
    title = in_title
    AND creator_tid = in_creator_id;

IF existing_tid IS NOT NULL THEN
SET
    custom_error = CONCAT (
        in_title,
        ' program already exists. You can view and edit program ID: ',
        existing_tid
    );

SIGNAL SQLSTATE '45000';

END IF;

INSERT INTO
    dt_learning_programs (
        title,
        description,
        creator_tid,
        difficulty_level,
        image_path,
        price,
        access_period_months,
        available_slots,
        campus_hiring,
        sponsored,
        minimum_score,
        experience_from,
        experience_to,
        locations,
        employer_name,
        regret_message,
        eligibility_template_tid,
        invite_template_tid
    )
VALUES
    (
        in_title,
        in_description,
        in_creator_id,
        in_difficulty_level,
        in_image_path,
        in_price,
        in_access_period_months,
        in_available_slots,
        in_campus_hiring,
        in_sponsored,
        in_minimum_score,
        in_experience_from,
        in_experience_to,
        in_locations,
        in_employer_name,
        in_regret_message,
        in_eligibility_template_id,
        in_invite_template_id
    );

SET
    learning_program_id = LAST_INSERT_ID ();

IF in_sponsored = TRUE THEN
INSERT INTO
    dt_program_sponsorships (
        company_user_tid,
        learning_program_tid,
        seats_allocated
    )
VALUES
    (
        in_creator_id,
        learning_program_id,
        in_available_slots
    );

END IF;

INSERT INTO
    dt_invitees (learning_program_tid, name, email)
SELECT
    learning_program_id,
    i.name,
    i.email
FROM
    JSON_TABLE (
        in_invitees,
        '$[*]' COLUMNS (
            name VARCHAR(100) path '$.name',
            email VARCHAR(255) path '$.email'
        )
    ) as i;

SELECT
    JSON_OBJECT (
        'program_id',
        learning_program_id,
        'program_name',
        in_title
    ) AS result;

COMMIT;

END //
DELIMITER ;

CALL add_learning_program(
    'Advanced Data Science Certification',  -- in_title
    'A comprehensive program covering machine learning, big data analytics, and AI fundamentals',  -- in_description
    123,  -- in_creator_id (must exist in users table)
    'high',  -- in_difficulty_level
    '/images/data-science-cert.jpg',  -- in_image_path
    1999.99,  -- in_price
    12,  -- in_access_period_months
    50,  -- in_available_slots
    TRUE,  -- in_campus_hiring
    FALSE,  -- in_sponsored
    75,  -- in_minimum_score
    '2',  -- in_experience_from (years)
    '5',  -- in_experience_to (years)
    'Remote, Bangalore, Hyderabad',  -- in_locations
    'TechEd Inc.',  -- in_employer_name
    'We regret to inform you that your application was not successful this time',  -- in_regret_message
    456,  -- in_eligibility_template_id (must exist if not NULL)
    789,  -- in_invite_template_id (must exist if not NULL)
    JSON_ARRAY(  -- in_invitees
        JSON_OBJECT(
            'name', 'Rahul Sharma',
            'email', 'rahul.sharma@example.com'
        ),
        JSON_OBJECT(
            'name', 'Priya Patel',
            'email', 'priya.patel@example.com'
        )
    )
);