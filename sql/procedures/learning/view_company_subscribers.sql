DROP PROCEDURE IF EXISTS getCourseSubscribers;
DELIMITER $$

CREATE PROCEDURE getCourseSubscribers(
    IN p_learning_program_tid BIGINT UNSIGNED
)
BEGIN
    -- Returns subscribers for a specific learning program, including their highest assessment score
    SELECT JSON_OBJECT(
        'data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'enrollment_id',         e.tid,
                    'subscriber_name',       u.full_Name,
                    'program_title',         lp.title,
                    'completion_status', CASE WHEN e.status = "3" THEN "expired"
                                       WHEN e.status = "2" THEN "completed" 
                                       WHEN e.status = "1" THEN "in_progress"
                                       WHEN e.status= "0" THEN "not_started" END,
                    'progress_percentage',   e.progress_percentage,
                    'enrollment_date',       e.enrollment_date,
                    'expires_on',            e.expires_on,
                    'completed_at',          e.completed_at,
                    'certificate_issued',    e.certificate_issued,
                    'assessment_score',      IFNULL(s.total_score, 0)
                )
            ), JSON_ARRAY()
        )
    ) AS data
    FROM dt_learning_enrollments e
    INNER JOIN dt_users u ON e.user_tid = u.tid
    INNER JOIN dt_learning_programs lp ON e.learning_program_tid = lp.tid
    LEFT JOIN (
        -- Get max score of any assessment attempt per user
        SELECT user_tid, MAX(score) AS total_score
        FROM dt_assessment_attempts
        GROUP BY user_tid
    ) s ON s.user_tid = u.tid
    WHERE lp.tid = p_learning_program_tid;
END $$
DELIMITER ;
