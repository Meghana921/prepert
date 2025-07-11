DROP PROCEDURE IF EXISTS learning_enrollment;
DELIMITER //

CREATE PROCEDURE learning_enrollment(
  IN in_user_id BIGINT,
  IN in_program_id BIGINT,
  IN in_status VARCHAR(10))
BEGIN 
  DECLARE expire_date DATE;
  DECLARE access_months INT;
  DECLARE enrollment_id BIGINT;
  DECLARE available_slots INT;
  DECLARE current_enrollments INT;
  DECLARE email_id VARCHAR(100);
  DECLARE custom_error VARCHAR(255);
  DECLARE program_sponsorship_id BIGINT;
  DECLARE error_message VARCHAR(255);
  
  -- Handle errors and rollback on failure
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 error_message= MESSAGE_TEXT;
    ROLLBACK;
    SET custom_error = COALESCE(custom_error,error_message);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END;

  START TRANSACTION;

  -- Validate program exists
  IF NOT EXISTS (SELECT 1 FROM dt_learning_programs WHERE tid = in_program_id) THEN
    SET custom_error = 'Program not found';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Prevent duplicate enrollments
  IF EXISTS (SELECT 1 FROM dt_learning_enrollments 
            WHERE user_tid = in_user_id AND learning_program_tid = in_program_id) THEN
    SET custom_error = 'User is already enrolled in this program';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Check program capacity if slots are limited
  SELECT available_slots, access_period_months INTO available_slots, access_months
  FROM dt_learning_programs WHERE tid = in_program_id;
  
  IF (available_slots) THEN
    SELECT COUNT(tid) INTO current_enrollments
    FROM dt_learning_enrollments WHERE learning_program_tid = in_program_id;

    IF current_enrollments >= available_slots THEN
      SET custom_error = 'No available slots in this program';
      SIGNAL SQLSTATE '45000';
    END IF;
  END IF;

  -- Calculate access expiration date
  SET expire_date = IFNULL(
    CASE WHEN access_months > 0 THEN DATE_ADD(CURRENT_DATE(), INTERVAL access_months MONTH)
    ELSE NULL END,
    NULL
  );

  -- Create enrollment record
  INSERT INTO dt_learning_enrollments(user_tid, learning_program_tid, expires_on)
  VALUES (in_user_id, in_program_id, expire_date);
  SET enrollment_id = LAST_INSERT_ID();

  -- Handle sponsored program enrollment
  IF EXISTS (SELECT 1 FROM dt_learning_programs WHERE tid = in_program_id AND sponsored = TRUE) THEN
    UPDATE dt_program_sponsorships
    SET seats_used = seats_used + 1
    WHERE learning_program_tid = in_program_id;
    
    SELECT tid INTO program_sponsorship_id 
    FROM dt_program_sponsorships
    WHERE learning_program_tid = in_program_id;
    
    INSERT INTO dt_user_sponsorships(program_sponsorship_tid, user_tid, enrollment_tid) 
    VALUES(program_sponsorship_id, in_user_id, enrollment_id);
  END IF;

  -- Update invitee status if applicable
  IF (in_status IS NOT NULL) THEN
    SELECT email INTO email_id FROM dt_users WHERE tid = in_user_id;
 
    UPDATE dt_invitees
    SET enrollment_tid = enrollment_id,
        response_at = CURRENT_TIMESTAMP,
        status = CASE WHEN in_status = "accepted" THEN "1"
                     WHEN in_status = "declined" THEN "3" END 
    WHERE program_tid = in_program_id AND email = email_id;
  END IF;

  COMMIT;

  -- Return enrollment confirmation
  SELECT JSON_OBJECT(
    'enrollment_id', enrollment_id,
    'program_id', in_program_id,
    'expires_on', expire_date
  ) AS data;
END //

DELIMITER ;

call learning_enrollment(4,1,"accepted")