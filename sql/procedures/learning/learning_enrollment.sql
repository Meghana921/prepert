DROP PROCEDURE IF EXISTS learning_enrollment;
DELIMITER //

CREATE PROCEDURE learning_enrollment(
  IN in_user_id BIGINT,
  IN in_program_id BIGINT
)
BEGIN 
  DECLARE expire_date DATE;
  DECLARE access_months INT;
  DECLARE enrollment_id BIGINT;
  DECLARE available_slots INT;
  DECLARE current_enrollments INT;
  DECLARE email_id VARCHAR(100);
  DECLARE custom_error VARCHAR(255);
  DECLARE  program_sponsorship_id BIGINT;
   DECLARE error_message VARCHAR(255);
    -- Error handler for rollback and exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    GET DIAGNOSTICS CONDITION 1
    error_message= MESSAGE_TEXT;
    ROLLBACK;
    SET custom_error = COALESCE(custom_error,error_message);
    SIGNAL SQLSTATE '45000'
    
        SET MESSAGE_TEXT = custom_error;
END;


  START TRANSACTION;

  -- 1. Check if the program exists
  IF NOT EXISTS (
    SELECT 1 FROM dt_learning_programs WHERE tid = in_program_id
  ) THEN
    SET custom_error = 'Program not found';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
  END IF;

  -- 2. Check if the user is already enrolled in the program
  IF EXISTS (
    SELECT 1 FROM dt_learning_enrollments 
    WHERE user_tid = in_user_id AND learning_program_tid = in_program_id
  ) THEN
    SET custom_error = 'User is already enrolled in this program';
    SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
  END IF;

  -- 3. Check for available slots in the program
  SELECT available_slots, access_period_months INTO available_slots, access_months
  FROM dt_learning_programs 
  WHERE tid = in_program_id;

  SELECT COUNT(tid) INTO current_enrollments
  FROM dt_learning_enrollments 
  WHERE learning_program_tid = in_program_id;

  IF current_enrollments >= available_slots THEN
    SET custom_error = 'No available slots in this program';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- 4. Calculate expiry date based on access period
  SET expire_date = IFNULL(
    CASE 
      WHEN access_months > 0 THEN DATE_ADD(CURRENT_DATE(), INTERVAL access_months MONTH)
      ELSE NULL
    END,
    NULL
  );

  -- 5. Insert the enrollment record
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

  -- 6. If program is sponsored, update the seats used in sponsorship table
  IF EXISTS (
    SELECT 1 FROM dt_learning_programs 
    WHERE tid = in_program_id AND sponsored = TRUE
  ) THEN
    UPDATE dt_program_sponsorships
    SET seats_used = seats_used + 1
    WHERE learning_program_tid = in_program_id;
    
    SELECT tid INTO program_sponsorship_id FROM dt_program_sponsorships
    WHERE learning_program_tid= in_program_id;
    
    INSERT INTO dt_user_sponsorships(program_sponsorship_tid,user_tid,enrollment_tid) VALUES( program_sponsorship_id,in_user_id,enrollment_id);
  END IF;

  -- 7. Update the invitee record with enrollment and response time if exists
  SELECT email INTO email_id 
  FROM dt_users 
  WHERE tid = in_user_id;

  IF email_id IS NOT NULL THEN
    UPDATE dt_invitees
    SET 
      enrollment_tid = enrollment_id,
      response_at = CURRENT_TIMESTAMP,
      status ='1'
    WHERE 
      learning_program_tid = in_program_id 
      AND email = email_id;
  END IF;


  COMMIT;

  -- 8. Return the result in JSON format
  SELECT JSON_OBJECT(
      'enrollment_id', enrollment_id,
      'user_id', in_user_id,
      'program_id', in_program_id,
      'expires_on', expire_date
  ) AS data;

END //

DELIMITER ;
