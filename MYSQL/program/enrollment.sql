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
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT COALESCE(custom_error, 'Error processing enrollment') AS error;
  END;

  START TRANSACTION;

  -- Check if enrollment already exists
 IF( SELECT 1 
  FROM dt_learning_enrollments
  WHERE user_tid = in_user_id AND learning_program_tid = in_program_id ) THEN
    SET custom_error = 'User is already enrolled in this program';
    SIGNAL SQLSTATE '45000';
  END IF;

  -- Check if program exists
  IF  (SELECT 0 FROM dt_learning_programs WHERE tid = in_program_id) THEN
    SET custom_error = 'Program not found';
    SIGNAL SQLSTATE '45000';
  END IF;

  SELECT access_period_months INTO access_months
  FROM dt_learning_programs
  WHERE tid = in_program_id;

  IF access_months IS NOT NULL AND access_months > 0 THEN
    SET expire_date = DATE_ADD(CURRENT_DATE(), INTERVAL access_months MONTH);
  ELSE
    SET expire_date = NULL; 
  END IF;

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
UPDATE dt_program_sponsorships
SET seats_used = seats_used + 1
WHERE learning_program_tid = in_program_id
AND (seats_used ) < seats_allocated;  -- Return success response
  SELECT enrollment_id as enrollment_id;

    

  COMMIT;
END $$
DELIMITER ;

call learning_enrollment(42,17);
