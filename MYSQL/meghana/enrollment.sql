DROP PROCEDURE IF EXISTS learning_enrollment;
DELIMITER $$
CREATE PROCEDURE learning_enrollment(
  IN in_user_id BIGINT,
  IN in_program_id BIGINT
)
BEGIN 
  DECLARE expire_date DATE;
  DECLARE access_months INT;
  DECLARE enrollment_exists INT DEFAULT 0;
  DECLARE custom_error VARCHAR(255);
  DECLARE enrollment_id BIGINT;
  DECLARE email_id VARCHAR(100);
  DECLARE available_slots INT;
  DECLARE current_enrollments INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error,"Failed to enrol!") as message;
  END;

  START TRANSACTION;

  -- Check if program exists
  IF NOT EXISTS (SELECT 1 FROM dt_learning_programs WHERE tid = in_program_id) THEN
    SET custom_error = 'Program not found';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Check if enrollment already exists
  IF EXISTS (SELECT 1 FROM dt_learning_enrollments 
            WHERE user_tid = in_user_id AND learning_program_tid = in_program_id) THEN
    SET custom_error = 'User is already enrolled in this program';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Check slot availability
  SELECT available_slots INTO available_slots 
  FROM dt_learning_programs WHERE tid = in_program_id;
  
  SELECT COUNT(*) INTO current_enrollments 
  FROM dt_learning_enrollments WHERE learning_program_tid = in_program_id;
  
  IF available_slots > 0 AND current_enrollments >= available_slots THEN
    SET custom_error = 'No available slots in this program';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Calculate expiration date
  SELECT access_period_months INTO access_months
  FROM dt_learning_programs WHERE tid = in_program_id;

  SET expire_date = CASE 
    WHEN access_months IS NOT NULL AND access_months > 0 
    THEN DATE_ADD(CURRENT_DATE(), INTERVAL access_months MONTH)
    ELSE NULL
  END;

  -- Create new enrollment
  INSERT INTO dt_learning_enrollments(
    user_tid, 
    learning_program_tid,
    expires_on
  ) VALUES (
    in_user_id,
    in_program_id,
    expire_date
  );
  
  SET enrollment_id = LAST_INSERT_ID();

  -- Update sponsorship seats if sponsored
  IF EXISTS (SELECT 1 FROM dt_learning_programs WHERE tid = in_program_id AND sponsored = TRUE) THEN
    UPDATE dt_program_sponsorships
    SET seats_used = seats_used + 1
    WHERE learning_program_tid = in_program_id;
  END IF;

  -- Update invitee record if exists
  SELECT email INTO email_id FROM dt_users WHERE tid = in_user_id;
  
  IF email_id IS NOT NULL THEN
    UPDATE dt_invitees
    SET enrollment_tid = enrollment_id
    WHERE learning_program_tid = in_program_id AND email = email_id;
  END IF;

  COMMIT;
  
  SELECT enrollment_id AS enrollment_id;
END $$
DELIMITER ;


call learning_enrollment(1,1);
