DROP PROCEDURE IF EXISTS update_learning_program;
DELIMITER $$

-- Updates an existing learning program with new details and maintains data consistency
CREATE PROCEDURE update_learning_program(
  IN in_program_id BIGINT,
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
  DECLARE custom_error VARCHAR(255);
  DECLARE program_exists INT DEFAULT 0;
  DECLARE error_message VARCHAR(255);

  -- Error handler to rollback on failure and preserve data integrity
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 error_message= MESSAGE_TEXT;
    ROLLBACK;
    SET custom_error = COALESCE(custom_error,error_message);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END;

  START TRANSACTION;

  -- Verify program exists and belongs to requesting creator
  IF NOT EXISTS (SELECT 1 FROM dt_learning_programs
                WHERE tid = in_program_id AND creator_tid = in_creator_id) THEN
    SET custom_error = 'Program not found!';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
  END IF;

  -- Update all program attributes
  UPDATE dt_learning_programs
  SET 
    title = in_title,
    description = in_description,
    difficulty_level = CASE WHEN in_difficulty_level = 'easy' THEN '0'
                           WHEN in_difficulty_level = 'medium' THEN '1'
                           WHEN in_difficulty_level = 'high' THEN '2'
                           ELSE '3' END,
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
    invite_template_tid = in_invite_template_id,
    is_public = in_public 
  WHERE tid = in_program_id;

  -- Prevent duplicate program names for same creator
  IF EXISTS (SELECT COUNT(tid) AS cnt FROM dt_learning_programs
            WHERE title=in_title AND creator_tid = in_creator_id
            GROUP BY creator_tid
            HAVING cnt >1) THEN
    SET custom_error = 'Program already exists in this name!';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
  END IF;

  -- Update expiration dates for all existing enrollments
  UPDATE dt_learning_enrollments 
  SET expires_on = DATE_ADD(enrollment_date, INTERVAL in_access_period_months MONTH)
  WHERE learning_program_tid = in_program_id;
  
  -- Handle sponsorship cancellation if needed
  IF (NOT in_sponsored) THEN
    UPDATE dt_program_sponsorships
    SET is_sponsorship_cancelled = TRUE
    WHERE learning_program_tid = in_program_id;
  END IF;

  COMMIT;

  -- Return success response with updated program info
  SELECT JSON_OBJECT(
      'program_id', in_program_id,
      'program_title', in_title
  ) AS data;
END $$

DELIMITER ;