DROP PROCEDURE IF EXISTS view_learning_program_with_progress;
DELIMITER //

CREATE PROCEDURE view_learning_program_with_progress(
  IN in_program_id BIGINT UNSIGNED,
  IN in_user_id BIGINT UNSIGNED
)
BEGIN
  DECLARE enrollment_id BIGINT;

  -- Get enrollment id
  SELECT tid INTO enrollment_id
  FROM dt_learning_enrollments
  WHERE user_tid = in_user_id AND learning_program_tid = in_program_id
  LIMIT 1;

  -- Main output
  SELECT JSON_OBJECT(
    'id', p.tid,
    'type', 'learning',
    'title', p.title,
    'description', p.description,
    'progressPercentage', (
      SELECT progress_percentage 
      FROM dt_learning_enrollments 
      WHERE tid = enrollment_id
    ),
    'modules', (
      SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
          'id', m.tid,
          'title', m.title,
          'isCompleted', (
            SELECT 
              CASE 
                WHEN COUNT(*) = 0 THEN FALSE
                WHEN COUNT(*) = (
                    SELECT COUNT(*) FROM dt_learning_items i WHERE i.module_tid = m.tid
                ) THEN TRUE
                ELSE FALSE
              END
            FROM dt_learning_items i
            LEFT JOIN dt_learning_progress p ON p.topic_tid = i.tid AND p.enrollment_tid = enrollment_id
            WHERE i.module_tid = m.tid
          ),
          'items', (
            SELECT JSON_ARRAYAGG(
              JSON_OBJECT(
                'id', i.tid,
                'title', i.title,
                'isCompleted', IF(p.topic_tid IS NOT NULL, TRUE, FALSE),
                'content', i.content
              )
            )
            FROM dt_learning_items i
            LEFT JOIN dt_learning_progress p 
              ON p.topic_tid = i.tid AND p.enrollment_tid = enrollment_id
            WHERE i.module_tid = m.tid
          )
        )
      )
      FROM dt_learning_modules m
      WHERE m.program_tid = p.tid
    )
  ) AS program_json
  FROM dt_learning_programs p
  WHERE p.tid = in_program_id;
END //

DELIMITER ;
