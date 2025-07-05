DROP PROCEDURE IF EXISTS getCourseSubscribers;
DELIMITER $$

CREATE PROCEDURE getCourseSubscribers(
    IN p_learning_program_tid BIGINT UNSIGNED
)
BEGIN
    SELECT JSON_OBJECT(
        'data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'enrollment_id',         e.tid,
                    'subscriber_name',       u.fullName,
                    'subscriber_email',      u.email,
                    'subscriber_phone',      u.phone,
                    'program_title',         lp.title,
                    'enrollment_status',     e.status,
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
    INNER JOIN dtusers u 
        ON e.user_tid = u.tid
    INNER JOIN dt_learning_programs lp 
        ON e.learning_program_tid = lp.tid
    LEFT JOIN (
        SELECT a.user_tid, SUM(a.total_score) AS total_score
        FROM dt_topic_assessments a
        INNER JOIN dt_learning_topics t ON a.topic_tid = t.tid
        INNER JOIN dt_learning_modules m ON t.module_tid = m.tid
        WHERE m.learning_program_tid = p_learning_program_tid
        GROUP BY a.user_tid
    ) s ON s.user_tid = u.tid
    WHERE lp.tid = p_learning_program_tid;
END $$
DELIMITER ;

call getCourseSubscribers(18);