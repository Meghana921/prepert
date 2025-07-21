DROP PROCEDURE IF EXISTS view_learning_program_with_progress;
DELIMITER //

CREATE PROCEDURE view_learning_program_with_progress(
  IN in_program_id BIGINT UNSIGNED,   -- Program ID to fetch
  IN in_user_id BIGINT UNSIGNED       -- User ID to track progress
)
BEGIN
  DECLARE enrollment_id BIGINT;

  -- Get the enrollment ID for the user and program
  SELECT tid INTO enrollment_id
  FROM dt_learning_enrollments
  WHERE user_tid = in_user_id AND learning_program_tid = in_program_id
  LIMIT 1;

  -- Return structured JSON containing program details, modules, topics, and progress
  SELECT JSON_OBJECT(
    'id', p.tid,
    'type', 'learning',
    'title', p.title,
    'description', p.description,

    -- Overall user progress in the program
    'progressPercentage', (
      SELECT progress_percentage 
      FROM dt_learning_enrollments 
      WHERE tid = enrollment_id
    ),

    -- Modules included in the program
    'modules', (
      SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
          'id', CONCAT(m.tid),
          'title', m.title,

          -- Topics under the module with completion info
          'items', (
            SELECT JSON_ARRAYAGG(
              JSON_OBJECT(
                'id', CONCAT(t.tid),
                'title', t.title,
                'isCompleted', IF(p.status = 2, TRUE, FALSE),
                'content', t.content
              )
            )
            FROM dt_learning_topics t
            LEFT JOIN dt_learning_progress p 
              ON p.topic_tid = t.tid AND p.enrollment_tid = enrollment_id
            WHERE t.module_tid = m.tid
            ORDER BY t.sequence_number
          )
        )
      )
      FROM dt_learning_modules m
      WHERE m.learning_program_tid = p.tid
      ORDER BY m.sequence_number
    )
  ) AS program_json
  FROM dt_learning_programs p
  WHERE p.tid = in_program_id;
END //

DELIMITER ;
