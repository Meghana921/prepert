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
  IN in_invite_template_id BIGINT,
  IN in_invitees JSON
)
BEGIN
  DECLARE custom_error VARCHAR(255);
   DECLARE expire_date DATE;
  DECLARE access_months INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error, 'Error updating program') AS message;
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
       



DELETE FROM dt_invitees 
  WHERE learning_program_tid = in_program_id;


  IF in_invitees IS NOT NULL AND JSON_LENGTH(in_invitees) > 0 THEN
    INSERT INTO dt_invitees (learning_program_tid, name, email)
    SELECT 
      in_program_id,
      JSON_UNQUOTE(JSON_EXTRACT(invitee, '$.name')),
      JSON_UNQUOTE(JSON_EXTRACT(invitee, '$.email'))
    FROM JSON_TABLE(
      in_invitees,
      '$[*]' COLUMNS(
        invitee JSON PATH '$'
      )
    ) AS invites;
  END IF;


  SELECT JSON_OBJECT(
    'program_id', in_program_id,
     'program_title',in_title
  ) AS data;
  COMMIT;
END $$
DELIMITER ;