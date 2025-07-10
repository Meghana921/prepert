DROP PROCEDURE IF EXISTS view_learning_program_with_progress;
DELIMITER //

CREATE PROCEDURE view_learning_program_with_progress(
  IN in_program_id BIGINT UNSIGNED,
  IN in_user_id BIGINT UNSIGNED
)
BEGIN
  DECLARE enrollment_id BIGINT;

  -- Step 1: Fetch the enrollment ID for the given user and program
  SELECT tid INTO enrollment_id
  FROM dt_learning_enrollments
  WHERE user_tid = in_user_id AND learning_program_tid = in_program_id
  LIMIT 1;

  -- Step 2: Build and return structured JSON with program, modules, items and progress
  SELECT JSON_OBJECT(
    'id', p.tid,
    'type', 'learning',
    'title', p.title,
    'description', p.description,

    -- Step 2a: User's progress percentage from dt_learning_enrollments
    'progressPercentage', (
      SELECT progress_percentage 
      FROM dt_learning_enrollments 
      WHERE tid = enrollment_id
    ),

    -- Step 2b: Array of modules
    'modules', (
      SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
          'id', concat(m.tid),
          'title', m.title,


          -- Step 2d: List of items (topics) in the module with completion status
          'items', (
            SELECT JSON_ARRAYAGG(
              JSON_OBJECT(
                'id',concat(t.tid),
                'title', t.title,
                'isCompleted', IF(p.status = 1, TRUE, FALSE),
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