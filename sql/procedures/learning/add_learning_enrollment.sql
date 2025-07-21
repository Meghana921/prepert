DROP PROCEDURE IF EXISTS learning_enrollment;
DELIMITER //

CREATE PROCEDURE learning_enrollment(
  IN in_user_id BIGINT,       -- ID of the user to enroll
  IN in_program_id BIGINT     -- ID of the learning program
)
BEGIN 
  -- Declare variables
  DECLARE expire_date DATE;
  DECLARE access_months INT;
  DECLARE enrollment_id BIGINT;
  DECLARE email_id VARCHAR(100);
  DECLARE custom_error VARCHAR(255);
  DECLARE error_message VARCHAR(255);
  DECLARE program_sponsorship_id BIGINT;
  DECLARE is_sponsred BOOLEAN DEFAULT FALSE;

  -- Error handler for rollback and exception capture
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
    ROLLBACK;
    SET custom_error = COALESCE(custom_error, error_message);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END;

  START TRANSACTION;

  -- Check if the program exists and is valid
  IF NOT EXISTS (
    SELECT 1 
    FROM dt_learning_programs 
    WHERE tid = in_program_id AND deleted_at IS NULL AND creator_tid IS NOT NULL
  ) THEN
    SET custom_error = 'Program not found!';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Check for existing enrollment
  IF EXISTS (
    SELECT 1 
    FROM dt_learning_enrollments 
    WHERE user_tid = in_user_id AND learning_program_tid = in_program_id
  ) THEN
    SET custom_error = 'User is already enrolled in this program';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;
 
  -- Get access period from the program
  SELECT access_period_months INTO access_months
  FROM dt_learning_programs 
  WHERE tid = in_program_id;

  -- Calculate expiration date based on access period
  SET expire_date = IFNULL(
    CASE 
      WHEN access_months > 0 THEN DATE_ADD(CURRENT_DATE(), INTERVAL access_months MONTH)
      ELSE NULL 
    END,
    NULL
  );

  -- Check and apply program sponsorship if available
  SELECT tid INTO program_sponsorship_id 
  FROM dt_program_sponsorships
  WHERE learning_program_tid = in_program_id AND seats_used < seats_allocated AND is_cancelled = false
  LIMIT 1;

  IF program_sponsorship_id IS NOT NULL THEN 
    SET is_sponsred = TRUE;

    -- Update used seats count
    UPDATE dt_program_sponsorships
    SET seats_used = seats_used + 1
    WHERE tid = program_sponsorship_id;
  END IF;

  -- Insert the enrollment record
  INSERT INTO dt_learning_enrollments(user_tid, learning_program_tid, expires_on, sponsered)
  VALUES (in_user_id, in_program_id, expire_date, is_sponsred);

  SET enrollment_id = LAST_INSERT_ID();

  -- Get user's email ID
  SELECT email INTO email_id 
  FROM dt_users 
  WHERE tid = in_user_id;

  -- Update invitee record if email matches
  UPDATE dt_invitees
  SET enrollment_tid = enrollment_id,
      status = '3'
  WHERE program_tid = in_program_id AND email = email_id AND email_status = '1';
  
  COMMIT;

  -- Return final response as JSON
  SELECT JSON_OBJECT(
    'enrollment_id', enrollment_id,
    'program_id', in_program_id,
    'expires_on', expire_date
  ) AS data;
END //

DELIMITER ;
