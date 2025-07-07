DROP PROCEDURE IF EXISTS list_user_subscribed_programs;
DELIMITER //

CREATE PROCEDURE list_user_subscribed_programs(
  IN in_user_id BIGINT UNSIGNED
)
BEGIN
  SELECT JSON_ARRAYAGG(
           JSON_OBJECT(
             'program_id', lp.tid,
             'title', lp.title,
             'description', lp.description,
             'status', e.status,
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
