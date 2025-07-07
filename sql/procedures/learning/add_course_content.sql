DELIMITER $$

DROP PROCEDURE IF EXISTS insert_learning_modules_and_topics $$
CREATE PROCEDURE insert_learning_modules_and_topics (
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

  -- Cursor declaration
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

  -- Handler declaration
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Temporary table for module_id to tid mapping
  DROP TEMPORARY TABLE IF EXISTS temp_module_map;
  CREATE TEMPORARY TABLE temp_module_map (
    module_id INT,
    module_tid BIGINT
  );

  OPEN module_cursor;

  read_loop: LOOP
    FETCH module_cursor INTO v_module_id, v_module_title, v_module_desc, v_module_seq;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Insert module
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

    -- Save mapping
    INSERT INTO temp_module_map (module_id, module_tid)
    VALUES (v_module_id, v_inserted_module_tid);
  END LOOP;

  CLOSE module_cursor;

  -- Insert topics
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


END $$
DELIMITER ;

