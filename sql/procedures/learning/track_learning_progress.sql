DROP PROCEDURE IF EXISTS track_learning_progess;
DELIMITER //

CREATE PROCEDURE track_learning_progess(
  IN user_id BIGINT UNSIGNED,
  IN topic_id BIGINT UNSIGNED
)
BEGIN
  DECLARE enrollment_id BIGINT UNSIGNED;
  DECLARE progress TINYINT;
  DECLARE tid BIGINT UNSIGNED;

  START TRANSACTION;

  -- Step 1: Get the enrollment ID for the user and topic
  SELECT de.tid INTO enrollment_id
  FROM dt_learning_enrollments de
  LEFT JOIN dt_learning_modules dm ON de.learning_program_tid = dm.learning_program_tid
  LEFT JOIN dt_learning_topics dt ON dt.module_tid = dm.tid
  WHERE de.user_tid = user_id AND dt.tid = topic_id
  LIMIT 1;

  -- Step 2: Get the progress weight for the topic
  SELECT progress_weight INTO progress
  FROM dt_learning_topics
  WHERE tid = topic_id;

  -- Step 3: Insert progress tracking entry
  INSERT INTO dt_learning_progress(enrollment_tid, topic_tid, status)
  VALUES(enrollment_id, topic_id, '1');

  SET tid = LAST_INSERT_ID();

  -- Step 4: Update progress percentage and enrollment status
  UPDATE dt_learning_enrollments
  SET
    progress_percentage = IFNULL(progress_percentage, 0) + progress,
    status = CASE
               WHEN IFNULL(progress_percentage, 0) + progress >= 100 THEN 'completed'
               ELSE 'in_progress'
             END
  WHERE tid = enrollment_id;

  -- Step 5: Return the progress entry ID
  SELECT JSON_OBJECT('tid', tid) AS data;

  COMMIT;
END //

DELIMITER ;
