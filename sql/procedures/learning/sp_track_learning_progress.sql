DROP procedure IF EXISTS track_learning_progess;
DELIMITER //
CREATE PROCEDURE track_learning_progess(IN user_id BIGINT UNSIGNED, IN topic_id BIGINT UNSIGNED)
BEGIN
DECLARE enrollment_id BIGINT UNSIGNED ;
DECLARE progress TINYINT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN 
ROLLBACK;
END;
START TRANSACTION;

SELECT de.tid  into enrollment_id FROM dt_learning_enrollments de
JOIN dt_learning_modules dm ON de.learning_program_tid = dm.learning_program_tid
JOIN dt_learning_topics dt ON dt.module_tid = dm.tid
WHERE user_tid = 1 AND dt.tid = 1;

 SELECT progress_weight into progress FROM  dt_learning_topics WHERE tid = topic_id;

INSERT INTO dt_learning_progress(enrollment_tid, topic_tid,status) VALUES(enrollment_id,topic_id,1);
UPDATE dt_learning_enrollments
SET  progress_percentage =  progress_percentage+progress,
status = CASE WHEN progress_percentage+progress= 100 THEN "2" ELSE "1" END;

COMMIT;
END //
DELIMITER ;

