DELIMITER $$

DROP PROCEDURE IF EXISTS update_learning_modules_and_topics $$
CREATE PROCEDURE update_learning_modules_and_topics (
  IN in_program_id BIGINT,
  IN in_modules_json JSON
)
BEGIN
  -- Variable declarations
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_module_id INT;
  DECLARE v_module_title VARCHAR(100);
  DECLARE v_module_desc TEXT;
  DECLARE v_module_seq INT;
  DECLARE v_inserted_module_tid BIGINT;
  DECLARE error_message TEXT;
  DECLARE custom_error TEXT;

  -- Cursor declaration
  DECLARE module_cursor CURSOR FOR
    SELECT 
      module_id,
      title,
      description,
      sequence_number
    FROM JSON_TABLE(
      in_modules_json,
      '$[*]' COLUMNS (
        module_id FOR ORDINALITY,
        title VARCHAR(100) PATH '$.title',
        description TEXT PATH '$.description',
        sequence_number INT PATH '$.sequence_number'
      )
    ) AS mod_tbl;

  -- Cursor end handler
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Error handler for rollback
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
    SET custom_error = COALESCE(custom_error, error_message);
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END;

  -- Start transaction
  START TRANSACTION;

  -- Check for duplicate module titles
  IF EXISTS (
    SELECT title
    FROM JSON_TABLE(
      in_modules_json,
      '$[*]' COLUMNS (
        title VARCHAR(100) PATH '$.title'
      )
    ) AS t
    GROUP BY title
    HAVING COUNT(*) > 1
  ) THEN
    SET custom_error = 'Duplicate module titles found in input.';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Check for duplicate topic titles within each module
  IF EXISTS (
    SELECT mod_outer.module_id, topic.title
    FROM JSON_TABLE (
      in_modules_json,
      '$[*]' COLUMNS (
        module_id FOR ORDINALITY,
        topics JSON PATH '$.topics'
      )
    ) AS mod_outer
    JOIN JSON_TABLE (
      mod_outer.topics,
      '$[*]' COLUMNS (
        title VARCHAR(100) PATH '$.title'
      )
    ) AS topic
    GROUP BY mod_outer.module_id, topic.title
    HAVING COUNT(*) > 1
  ) THEN
    SET custom_error = 'Duplicate topic titles found within the same module.';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
  END IF;

  -- Delete old topics for this program
  DELETE FROM dt_learning_topics 
  WHERE module_tid IN (
    SELECT tid FROM dt_learning_modules WHERE learning_program_tid = in_program_id
  );

  -- Delete old modules for this program
  DELETE FROM dt_learning_modules
  WHERE learning_program_tid = in_program_id;

  -- Temp table to map ordinal module_id → inserted tid
  DROP TEMPORARY TABLE IF EXISTS temp_module_map;
  CREATE TEMPORARY TABLE temp_module_map (
    module_id INT,
    module_tid BIGINT
  );

  -- Insert modules from JSON
  OPEN module_cursor;

  read_loop: LOOP
    FETCH module_cursor INTO v_module_id, v_module_title, v_module_desc, v_module_seq;
    IF done THEN
      LEAVE read_loop;
    END IF;

    INSERT INTO dt_learning_modules (
      learning_program_tid,
      title,
      description,
      sequence_number
    ) VALUES (
      in_program_id,
      v_module_title,
      v_module_desc,
      v_module_seq
    );

    SET v_inserted_module_tid = LAST_INSERT_ID();

    INSERT INTO temp_module_map (module_id, module_tid)
    VALUES (v_module_id, v_inserted_module_tid);
  END LOOP;

  CLOSE module_cursor;

  -- Insert topics using temp map
  INSERT INTO dt_learning_topics (
    module_tid,
    title,
    description,
    content,
    sequence_number,
    progress_weight
  )
  SELECT
    tm.module_tid,
    topic.title,
    topic.description,
    topic.content,
    topic.sequence_number,
    topic.progress_weight
  FROM JSON_TABLE (
    in_modules_json,
    '$[*]' COLUMNS (
      module_id FOR ORDINALITY,
      topics JSON PATH '$.topics'
    )
  ) AS mod_outer
  JOIN JSON_TABLE (
    mod_outer.topics,
    '$[*]' COLUMNS (
      title VARCHAR(100) PATH '$.title',
      description TEXT PATH '$.description',
      content TEXT PATH '$.content',
      sequence_number INT PATH '$.sequence_number',
      progress_weight INT PATH '$.progress_weight'
    )
  ) AS topic
  JOIN temp_module_map tm ON tm.module_id = mod_outer.module_id;

  -- Commit
  COMMIT;
END $$

DELIMITER ;
