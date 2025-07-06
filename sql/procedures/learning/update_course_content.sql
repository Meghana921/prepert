DELIMITER $$

DROP PROCEDURE IF EXISTS update_learning_modules_and_topics $$
CREATE PROCEDURE update_learning_modules_and_topics (
  IN in_program_id BIGINT,
  IN in_modules_json JSON
)
BEGIN
  -- Declare variables
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_module_id INT;
  DECLARE v_module_title VARCHAR(100);
  DECLARE v_module_desc TEXT;
  DECLARE v_module_seq INT;
  DECLARE v_inserted_module_tid BIGINT;

  -- Cursor for modules
  DECLARE module_cursor CURSOR FOR
    SELECT module_id, title, description, sequence_number
    FROM JSON_TABLE(
      in_modules_json,
      '$[*]' COLUMNS (
        module_id FOR ORDINALITY,
        title VARCHAR(100) PATH '$.title',
        description TEXT PATH '$.description',
        sequence_number INT PATH '$.sequence_number'
      )
    ) AS mod_tbl;

  -- Handler
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Delete existing modules and topics
  DELETE FROM dt_learning_topics 
  WHERE module_tid IN (
    SELECT tid FROM dt_learning_modules WHERE learning_program_tid = in_program_id
  );

  DELETE FROM dt_learning_modules
  WHERE learning_program_tid = in_program_id;

  -- Create temp table to map module index to inserted TID
  DROP TEMPORARY TABLE IF EXISTS temp_module_map;
  CREATE TEMPORARY TABLE temp_module_map (
    module_id INT,
    module_tid BIGINT
  );

  -- Start transaction
  START TRANSACTION;

  -- Insert new modules
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

  -- Insert topics using the new module_tid from temp table
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

  COMMIT;
END $$

DELIMITER ;
