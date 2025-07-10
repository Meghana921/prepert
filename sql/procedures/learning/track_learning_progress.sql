DROP PROCEDURE IF EXISTS track_learning_progess;
DELIMITER //
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
  
  START TRANSACTION;
  
  -- Step 1: Get the enrollment ID and program ID for the user and topic
  SELECT de.tid, de.learning_program_tid INTO enrollment_id, learning_program_id
  FROM dt_learning_enrollments de
  JOIN dt_learning_modules dm ON de.learning_program_tid = dm.learning_program_tid
  JOIN dt_learning_topics dt ON dt.module_tid = dm.tid
  WHERE de.user_tid = user_id AND dt.tid = topic_id
  LIMIT 1;
  
  -- Exit if no enrollment found
  IF enrollment_id IS NULL THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'No enrollment found for this user and topic';
  END IF;
  
  -- Step 2: Get the progress weight for the topic
  SELECT progress_weight INTO progress
  FROM dt_learning_topics
  WHERE tid = topic_id;
  
  -- Default to 1 if progress weight not set
  IF progress IS NULL THEN
    SET progress = 1;
  END IF;
  
  -- Step 3: Insert or update progress tracking entry (mark as completed)
  INSERT INTO dt_learning_progress(enrollment_tid, topic_tid, status)
  VALUES(enrollment_id, topic_id, '2')
  ON DUPLICATE KEY UPDATE 
    status = '2', 
    completion_date = CURRENT_TIMESTAMP;
  
  -- Get the actual tid of the progress record
  SELECT tid INTO result_tid 
  FROM dt_learning_progress 
  WHERE enrollment_tid = enrollment_id AND topic_tid = topic_id;
  
  -- Step 4: Calculate new progress percentage
  -- Get total topics in the specific program
  SELECT COUNT(*) INTO topic_count
  FROM dt_learning_topics dt
  JOIN dt_learning_modules dm ON dt.module_tid = dm.tid
  WHERE dm.learning_program_tid = learning_program_id;
  
  -- Get completed topics count for this enrollment
  SELECT COUNT(*) INTO completed_count
  FROM dt_learning_progress dp
  JOIN dt_learning_topics dt ON dp.topic_tid = dt.tid
  JOIN dt_learning_modules dm ON dt.module_tid = dm.tid
  WHERE dp.enrollment_tid = enrollment_id 
    AND dp.status = '2'
    AND dm.learning_program_tid = learning_program_id;
  
  -- Calculate new progress percentage
  IF topic_count > 0 THEN
    SET current_progress = ROUND((completed_count * 100.0) / topic_count);
  ELSE
    SET current_progress = 0;
  END IF;
  
  -- Ensure progress doesn't exceed 100
  IF current_progress > 100 THEN
    SET current_progress = 100;
  END IF;
  
  -- Step 5: Update enrollment with new progress and status
  UPDATE dt_learning_enrollments
  SET
    progress_percentage = current_progress,
    status = CASE
               WHEN current_progress >= 100 THEN '2' -- Completed
               WHEN current_progress > 0 THEN '1'   -- In Progress  
               ELSE '0'                             -- Enrolled
             END,
    completed_at = CASE
                     WHEN current_progress >= 100 THEN CURRENT_TIMESTAMP
                     ELSE completed_at
                   END,
    updated_at = CURRENT_TIMESTAMP
  WHERE tid = enrollment_id;
  
  -- Step 6: Return the progress entry ID and updated information
  SELECT JSON_OBJECT(
    'tid', result_tid,
    'enrollment_id', enrollment_id,
    'progress_percentage', current_progress,
    'topic_count', topic_count,
    'completed_count', completed_count,
    'status', CASE
                WHEN current_progress >= 100 THEN 'completed'
                WHEN current_progress > 0 THEN 'in_progress'
                ELSE 'enrolled'
              END
  ) AS data;
  
  COMMIT;
END //
DELIMITER ;