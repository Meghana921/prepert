DROP PROCEDURE IF EXISTS update_learning_modules_and_topics;
DELIMITER //

CREATE PROCEDURE update_learning_modules_and_topics (
  IN in_program_id BIGINT,           -- Input: Program ID whose modules and topics are to be updated
  IN in_modules_json JSON            -- Input: JSON array of modules (with nested topics)
)
BEGIN
  -- Declare variables for reading module data from JSON
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_module_id INT;           -- Ordinal index of module in JSON array
  DECLARE v_module_title VARCHAR(100);
  DECLARE v_module_desc TEXT;
  DECLARE v_module_seq INT;
  DECLARE v_inserted_module_tid BIGINT;

  -- Cursor to iterate over modules from JSON input
  DECLARE module_cursor CURSOR FOR
    SELECT module_id, title, description, sequence_number
    FROM JSON_TABLE(
      in_modules_json,
      '$[*]' COLUMNS (
        module_id FOR ORDINALITY,                  -- Module index to keep order
        title VARCHAR(100) PATH '$.title',
        description TEXT PATH '$.description',
        sequence_number INT PATH '$.sequence_number'
      )
    ) AS mod_tbl;

  -- Handler to set exit condition for loop
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Step 1: Delete existing topics for all modules in this program
  DELETE FROM dt_learning_topics 
  WHERE module_tid IN (
    SELECT tid FROM dt_learning_modules WHERE learning_program_tid = in_program_id
  );

  -- Step 2: Delete existing modules for this program
  DELETE FROM dt_learning_modules
  WHERE learning_program_tid = in_program_id;

  -- Step 3: Create a temporary table to map module index (ordinal) to newly inserted module TID
  DROP TEMPORARY TABLE IF EXISTS temp_module_map;
  CREATE TEMPORARY TABLE temp_module_map (
    module_id INT,           -- Ordinal index from JSON
    module_tid BIGINT        -- Newly inserted module TID from DB
  );

  -- Step 4: Start a transaction to ensure atomicity
  START TRANSACTION;

  -- Step 5: Insert each module from JSON and store its TID in temp map
  OPEN module_cursor;

  read_loop: LOOP
    FETCH module_cursor INTO v_module_id, v_module_title, v_module_desc, v_module_seq;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Insert the module
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

    -- Get the new module's TID
    SET v_inserted_module_tid = LAST_INSERT_ID();

    -- Map ordinal index to new module TID for later use with topics
    INSERT INTO temp_module_map (module_id, module_tid)
    VALUES (v_module_id, v_inserted_module_tid);

  END LOOP;

  CLOSE module_cursor;

  -- Step 6: Insert all topics using the temp mapping of module ordinal to DB TID
  INSERT INTO dt_learning_topics (
    module_tid,
    title,
    description,
    content,
    sequence_number,
    progress_weight
  )
  SELECT
    tm.module_tid,                  -- Use mapped TID for the current module
    topic.title,
    topic.description,
    topic.content,
    topic.sequence_number,
    topic.progress_weight
  FROM JSON_TABLE (
    in_modules_json,
    '$[*]' COLUMNS (
      module_id FOR ORDINALITY,     -- Outer index used to map back to temp_module_map
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

  -- Step 7: Commit the transaction
  COMMIT;
END //

DELIMITER ;
