DROP PROCEDURE IF EXISTS update_learning_program;
DELIMITER $$

CREATE PROCEDURE update_learning_program(
  IN in_program_id BIGINT,
  IN in_title VARCHAR(100),
  IN in_description TEXT,
  IN in_creator_id BIGINT,
  IN in_difficulty_level ENUM('low', 'medium', 'high', 'very_high'),
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
  IN in_invite_template_id BIGINT
)
BEGIN
  DECLARE custom_error VARCHAR(255);
   DECLARE expire_date DATE;
  DECLARE access_months INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT JSON_OBJECT('error', COALESCE(custom_error, 'Error updating program')) AS result;
  END;

  START TRANSACTION;

  -- Check if program exists
  IF (SELECT 0 
  FROM dt_learning_programs
  WHERE tid = in_program_id AND creator_tid = in_creator_id) THEN
    SET custom_error = 'Program not found!';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Update program
  UPDATE dt_learning_programs
  SET 
    title = in_title,
    description = in_description,
    difficulty_level = in_difficulty_level,
    image_path = in_image_path,
    price = in_price,
    access_period_months = in_access_period_months,
    available_slots = in_available_slots,
    campus_hiring = in_campus_hiring,
    sponsored = in_sponsored,
    minimum_score = in_minimum_score,
    experience_from = in_experience_from,
    experience_to = in_experience_to,
    locations = in_locations,
    employer_name = in_employer_name,
    regret_message = in_regret_message,
    eligibility_template_tid = in_eligibility_template_id,
    invite_template_tid = in_invite_template_id
  WHERE tid = in_program_id;

UPDATE dt_learning_enrollments 
SET expires_on = DATE_ADD(
                enrollment_date, 
                INTERVAL in_access_period_months MONTH
            )
WHERE learning_program_tid = in_program_id;
       

  -- Return success message
  SELECT JSON_OBJECT(
    'message', 'Program updated successfully',
    'program_id', in_program_id,
     'program_title',in_title
  ) AS data;

  COMMIT;
END $$
DELIMITER ;

CALL  update_learning_program(5,
  'Data Science Certification',                      -- in_title
  'Comprehensive 6-month program covering machine learning and big data', -- description
  15,                                                       -- creator_id (user ID who created this)
  'high',                                                   -- difficulty_level
  '/images/programs/data-science-advanced.jpg',             -- image_path
  2999.99,                                                  -- price
  5,                                                       -- access_period_months
  50,                                                       -- available_slots
  TRUE,                                                     -- campus_hiring
  FALSE,                                                    -- sponsored
  75,                                                       -- minimum_score
  '2',                                                      -- experience_from (years)
  '5',                                                      -- experience_to (years)
  'Bangalore,Hyderabad,Remote',                             -- locations
  'TechCorp Analytics',                                     -- employer_name
  'We appreciate your application but require more experience for this program', -- regret_message
  7,                                                        -- eligibility_template_id
  12                                                        -- invite_template_id
);