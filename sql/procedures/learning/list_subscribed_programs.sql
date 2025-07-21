DROP PROCEDURE IF EXISTS list_user_subscribed_programs;
DELIMITER //

-- Returns a JSON array of learning programs the user is enrolled in, along with enrollment details
CREATE PROCEDURE list_user_subscribed_programs(
  IN in_user_id BIGINT UNSIGNED
)
BEGIN
  -- Fetch all programs the user is enrolled in with status and progress details
  SELECT JSON_ARRAYAGG(
           JSON_OBJECT(
             'program_id', lp.tid,
             'title', lp.title,
             'description', lp.description,
             'completion_status', CASE WHEN e.status = "3" THEN "expired"
                                       WHEN e.status = "2" THEN "completed" 
                                       WHEN e.status = "1" THEN "in_progress"
                                       WHEN e.status= "0" THEN "not_started" END,
             'progress_percentage', e.progress_percentage,
             'enrollment_date', e.enrollment_date,
             'expires_on', e.expires_on
           )
         ) AS data
  FROM dt_learning_enrollments e
  JOIN dt_learning_programs lp ON lp.tid = e.learning_program_tid
  WHERE e.user_tid = in_user_id;
END //

DELIMITER ;
