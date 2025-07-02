DELIMITER $$

CREATE PROCEDURE sp_edit_course_content(
    IN p_content_type ENUM('module', 'topic'),         -- Content type to edit
    IN p_content_id BIGINT UNSIGNED,                   -- ID of the module or topic to edit
    IN p_content_json JSON,                            -- JSON object with updated fields
    IN p_learning_program_tid BIGINT UNSIGNED          -- Program to verify ownership
)
sp_block: BEGIN
    DECLARE v_module_exists INT DEFAULT 0;
    DECLARE v_topic_exists INT DEFAULT 0;
    DECLARE v_program_match INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- ===============================
    -- Edit MODULE
    -- ===============================
    IF p_content_type = 'module' THEN
        -- Check module exists and belongs to the program
        SELECT COUNT(*) INTO v_module_exists
        FROM dt_learning_modules
        WHERE tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_modules
        WHERE tid = p_content_id AND learning_program_tid = p_learning_program_tid;

        IF v_module_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Module not found';
        END IF;

        IF v_program_match = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Module does not belong to the specified program';
        END IF;

        -- Update the module
        UPDATE dt_learning_modules
        SET 
            title           = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.title')), title),
            description     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.description')), description),
            sequence_number = COALESCE(JSON_EXTRACT(p_content_json, '$.sequence_number'), sequence_number),
            updated_at      = NOW()
        WHERE tid = p_content_id;

        SELECT 'Module updated successfully' AS message;

    -- ===============================
    -- Edit TOPIC
    -- ===============================
    ELSEIF p_content_type = 'topic' THEN
        -- Check topic exists and belongs to the program
        SELECT COUNT(*) INTO v_topic_exists
        FROM dt_learning_topics t
        JOIN dt_learning_modules m ON t.module_tid = m.tid
        WHERE t.tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_topics t
        JOIN dt_learning_modules m ON t.module_tid = m.tid
        WHERE t.tid = p_content_id AND m.learning_program_tid = p_learning_program_tid;

        IF v_topic_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Topic not found';
        END IF;

        IF v_program_match = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Topic does not belong to the specified program';
        END IF;

        -- Update the topic
        UPDATE dt_learning_topics
        SET 
            title           = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.title')), title),
            description     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.description')), description),
            content         = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.content')), content),
            sequence_number = COALESCE(JSON_EXTRACT(p_content_json, '$.sequence_number'), sequence_number),
            progress_weight = COALESCE(JSON_EXTRACT(p_content_json, '$.progress_weight'), progress_weight),
            updated_at      = NOW()
        WHERE tid = p_content_id;

        SELECT 'Topic updated successfully' AS message;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid content type. Use module or topic.';
    END IF;

    COMMIT;
END sp_block $$

DELIMITER ;

-- Editing topic that does not belong to program 3001 (if any)
-- IN p_module_tid BIGINT UNSIGNED,
--     IN p_learning_program_tid BIGINT UNSIGNED,
--     IN p_new_title VARCHAR(100),
--     IN p_new_description TEXT,
--     IN p_new_sequence SMALLINT,
--     IN p_topics JSON
CALL sp_add_course_content(
  3001,
  'Indexes in SQL',
  'Learn about indexing strategies.',
  21,
  JSON_ARRAY(
    JSON_OBJECT('title','Index Basi','description','Intro to indexes','content','CREATE INDEX ...','sequence_number',1,'progress_weight',1),
    JSON_OBJECT('title','Unique Index','description','Ensuring uniqueness','content','CREATE UNIQUE INDEX ...','sequence_number',2,'progress_weight',2)
  )
);
CALL sp_edit_course_content(
  'topic',
  5001,
  JSON_OBJECT(
    'title','SP Overview',
    'description','Updated SP basics',
    'content','Stored procs are reusable blocks',
    'sequence_number',1,
    'progress_weight',2
  ),
  3001
);



