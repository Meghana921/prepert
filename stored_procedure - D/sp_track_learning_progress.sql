DELIMITER $$
drop procedure if exists sp_track_learning_progress;
CREATE PROCEDURE sp_track_learning_progress(
    IN  p_enrollment_tid   BIGINT UNSIGNED,
    IN  p_topic_tid        BIGINT UNSIGNED,
    IN  p_status           ENUM('not_started','in_progress','completed')
)
BEGIN
	DECLARE p_status_code      INT default 0;
    DECLARE p_message          VARCHAR(255) default '';
    DECLARE v_progress_exists    INT DEFAULT 0;
    DECLARE v_total_topics       INT DEFAULT 0;
    DECLARE v_completed_topics   INT DEFAULT 0;
    DECLARE v_progress_percentage TINYINT UNSIGNED DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_code = 500;
        SET p_message = 'Database error occurred while tracking progress';
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Check if a progress record exists for this enrollment/topic
    SELECT COUNT(*) INTO v_progress_exists
    FROM dt_learning_progress
    WHERE enrollment_tid = p_enrollment_tid
      AND topic_tid      = p_topic_tid;

    -- 2. Insert or update the per-topic progress (time_spent unchanged)
    IF v_progress_exists > 0 THEN
        UPDATE dt_learning_progress
        SET status          = p_status,
            completion_date = CASE
                                  WHEN p_status = 'completed' THEN NOW()
                                  ELSE completion_date
                              END,
            updated_at      = NOW()
        WHERE enrollment_tid = p_enrollment_tid
          AND topic_tid      = p_topic_tid;
    ELSE
        INSERT INTO dt_learning_progress (
            enrollment_tid,
            topic_tid,
            status,
            completion_date
        ) VALUES (
            p_enrollment_tid,
            p_topic_tid,
            p_status,
            CASE WHEN p_status = 'completed' THEN NOW() ELSE NULL END
        );
    END IF;

    -- 3. Compute total topics in this course
    SELECT COUNT(DISTINCT lt.tid) INTO v_total_topics
    FROM dt_learning_enrollments le
    JOIN dt_learning_programs  lp ON le.learning_program_tid = lp.tid
    JOIN dt_learning_modules   lm ON lp.tid                 = lm.learning_program_tid
    JOIN dt_learning_topics    lt ON lm.tid                 = lt.module_tid
    WHERE le.tid = p_enrollment_tid;

    -- 4. Count completed topics
    SELECT COUNT(*) INTO v_completed_topics
    FROM dt_learning_progress lpr
    WHERE lpr.enrollment_tid = p_enrollment_tid
      AND lpr.status         = 'completed';

    -- 5. Calculate overall percentage
    IF v_total_topics > 0 THEN
        SET v_progress_percentage = ROUND((v_completed_topics / v_total_topics) * 100);
    ELSE
        SET v_progress_percentage = 0;
    END IF;

    -- 6. Update enrollment record
    UPDATE dt_learning_enrollments
    SET progress_percentage = v_progress_percentage,
        status              = CASE
                                WHEN v_progress_percentage = 100 THEN 'completed'
                                WHEN v_progress_percentage >  0  THEN 'in_progress'
                                ELSE 'enrolled'
                              END,
        completed_at        = CASE
                                WHEN v_progress_percentage = 100 THEN NOW()
                                ELSE completed_at
                              END,
        updated_at          = NOW()
    WHERE tid = p_enrollment_tid;

    COMMIT;

    -- 7. Return status
    set p_status_code = 200;
    set p_message     = CONCAT(
                          'Progress updated successfully. Overall progress: ',
                          v_progress_percentage,
                          '%'
                       );
	select p_status_code as p_status_code,p_message as p_message;
				
END$$

DELIMITER ;

SET @status_code = NULL;
SET @message = NULL;

CALL sp_track_learning_progress(
  6001,
  5001,
  'completed'
);

SELECT @status_code, @message;

