DROP PROCEDURE IF EXISTS add_learning_program;
DELIMITER $$

CREATE PROCEDURE add_learning_program(
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
  DECLARE learning_program_id BIGINT;
  DECLARE existing_tid BIGINT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT JSON_OBJECT('error', COALESCE(custom_error, 'An error occurred during program creation')) AS result;
  END;

  START TRANSACTION;

  -- Checking if course already exists
  SELECT tid INTO existing_tid FROM dt_learning_programs
  WHERE title = in_title AND creator_tid = in_creator_id;
  
  IF existing_tid IS NOT NULL THEN 
    SET custom_error = CONCAT(in_title, ' program already exists. You can view and edit program ID: ', existing_tid);
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Inserting learning programs
  INSERT INTO dt_learning_programs (
    title, description, creator_tid, difficulty_level, image_path, price,
    access_period_months, available_slots, campus_hiring, sponsored, minimum_score,
    experience_from, experience_to, locations, employer_name, regret_message,
    eligibility_template_tid, invite_template_tid
  ) VALUES (
    in_title, in_description, in_creator_id, in_difficulty_level, in_image_path, in_price,
    in_access_period_months, in_available_slots, in_campus_hiring, in_sponsored, in_minimum_score,
    in_experience_from, in_experience_to, in_locations, in_employer_name, in_regret_message,
    in_eligibility_template_id, in_invite_template_id
  );

  SET learning_program_id = LAST_INSERT_ID();
  
  IF in_sponsored=TRUE THEN
    INSERT INTO dt_program_sponsorships(company_user_tid, learning_program_tid, seats_allocated)
    VALUES(in_creator_id, learning_program_id, in_available_slots);
  END IF;
  
  SELECT JSON_OBJECT(
    'program_id', learning_program_id,
    'program_name', in_title
  ) AS result;

  COMMIT;
END $$
DELIMITER ;