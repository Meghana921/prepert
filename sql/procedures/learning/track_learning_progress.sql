DROP PROCEDURE IF EXISTS track_learning_progess;
DELIMITER //

-- Tracks and updates a user's learning progress for a given topic, including enrollment status and progress percentage.
CREATE PROCEDURE track_learning_progess(
  IN user_id BIGINT UNSIGNED,
  IN topic_id BIGINT UNSIGNED
)
BEGIN
  DECLARE enrollment_id BIGINT UNSIGNED;
  DECLARE progress TINYINT;
  DECLARE result_tid BIGINT UNSIGNED;
  DECLARE current_progress TINYINT;
  DECLARE topic_count INT;
  DECLARE completed_count INT;
  DECLARE learning_program_id BIGINT UNSIGNED;
  DECLARE custom_error TEXT;
  DECLARE error_message TEXT;

  -- Rollback on any SQL error and raise the error message
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
    SET custom_error = COALESCE(custom_error, error_message);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END;

  START TRANSACTION;

  -- Get user's enrollment ID and related learning program for the given topic
  SELECT de.tid, de.learning_program_tid INTO enrollment_id, learning_program_id
  FROM dt_learning_enrollments de
  JOIN dt_learning_modules dm ON de.learning_program_tid = dm.learning_program_tid
  JOIN dt_learning_topics dt ON dt.module_tid = dm.tid
  WHERE de.user_tid = user_id AND dt.tid = topic_id
  LIMIT 1;

  -- Exit with error if enrollment doesn't exist
  IF enrollment_id IS NULL THEN
    SET custom_error = 'No enrollment found for this user and topic';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Mark the topic as completed (insert or update progress record)
  INSERT INTO dt_learning_progress(enrollment_tid, topic_tid, status)
  VALUES(enrollment_id, topic_id, '2')
  ON DUPLICATE KEY UPDATE 
    status = '2', 
    completion_date = CURRENT_TIMESTAMP;

  -- Get the progress record's ID
  SELECT tid INTO result_tid 
  FROM dt_learning_progress 
  WHERE enrollment_tid = enrollment_id AND topic_tid = topic_id;

  -- Count total topics in the learning program
  SELECT COUNT(dt.tid) INTO topic_count
  FROM dt_learning_topics dt
  JOIN dt_learning_modules dm ON dt.module_tid = dm.tid
  WHERE dm.learning_program_tid = learning_program_id;

  -- Count number of topics completed by the user in the same program
  SELECT COUNT(dp.tid) INTO completed_count
  FROM dt_learning_progress dp
  JOIN dt_learning_topics dt ON dp.topic_tid = dt.tid
  JOIN dt_learning_modules dm ON dt.module_tid = dm.tid
  WHERE dp.enrollment_tid = enrollment_id 
    AND dp.status = '1'
    AND dm.learning_program_tid = learning_program_id;

  -- Calculate progress percentage
  IF topic_count > 0 THEN
    SET current_progress = ROUND((completed_count * 100.0) / topic_count);
  ELSE
    SET current_progress = 0;
  END IF;

  -- Ensure progress does not exceed 100%
  IF current_progress > 100 THEN
    SET current_progress = 100;
  END IF;

  -- Update enrollment record with new progress and completion status
  UPDATE dt_learning_enrollments
  SET
    progress_percentage = current_progress,
    status = CASE
               WHEN current_progress >= 100 THEN '2'   -- Completed
               WHEN current_progress > 0 THEN '1'      -- In Progress
               ELSE '0'                                -- Just Enrolled
             END,
    completed_at = CASE
                     WHEN current_progress >= 100 THEN CURRENT_TIMESTAMP
                     ELSE completed_at
                   END,
    updated_at = CURRENT_TIMESTAMP
  WHERE tid = enrollment_id;

  COMMIT;
END //

DELIMITER ;
