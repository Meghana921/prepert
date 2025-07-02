DELIMITER //

CREATE PROCEDURE sp_add_course_content(
    IN p_learning_program_tid BIGINT UNSIGNED,
    IN p_module_title VARCHAR(100),
    IN p_module_description TEXT,
    IN p_module_sequence SMALLINT,
    IN p_topics JSON
)
sp_block: BEGIN
    DECLARE v_module_id BIGINT UNSIGNED;
    DECLARE v_topic_count INT DEFAULT 0;
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_topic_title VARCHAR(100);
    DECLARE v_topic_description TEXT;
    DECLARE v_topic_content TEXT;
    DECLARE v_topic_sequence SMALLINT;
    DECLARE v_progress_weight INT;
    DECLARE v_duplicate_module INT DEFAULT 0;

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Database error occurred while adding course content' AS message, 500 AS status_code;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Check if the module already exists
    SELECT COUNT(*) INTO v_duplicate_module
    FROM dt_learning_modules
    WHERE learning_program_tid = p_learning_program_tid
      AND title = p_module_title;

    IF v_duplicate_module > 0 THEN
        ROLLBACK;
        SELECT 'Duplicate module title under this program. Not inserted.' AS message, 409 AS status_code;
        LEAVE sp_block;
    END IF;

    -- Insert the module
    INSERT INTO dt_learning_modules (
        learning_program_tid,
        title,
        description,
        sequence_number
    ) VALUES (
        p_learning_program_tid,
        p_module_title,
        p_module_description,
        p_module_sequence
    );
    
    SET v_module_id = LAST_INSERT_ID();

    -- Count topics from JSON
    SET v_topic_count = JSON_LENGTH(p_topics);

    -- Insert topics
    WHILE v_counter < v_topic_count DO
        SET v_topic_title = JSON_UNQUOTE(JSON_EXTRACT(p_topics, CONCAT('$[', v_counter, '].title')));
        SET v_topic_description = JSON_UNQUOTE(JSON_EXTRACT(p_topics, CONCAT('$[', v_counter, '].description')));
        SET v_topic_content = JSON_UNQUOTE(JSON_EXTRACT(p_topics, CONCAT('$[', v_counter, '].content')));
        SET v_topic_sequence = JSON_EXTRACT(p_topics, CONCAT('$[', v_counter, '].sequence_number'));
        SET v_progress_weight = COALESCE(
            JSON_EXTRACT(p_topics, CONCAT('$[', v_counter, '].progress_weight')),
            1
        );

        INSERT INTO dt_learning_topics (
            module_tid,
            title,
            description,
            content,
            sequence_number,
            progress_weight
        ) VALUES (
            v_module_id,
            v_topic_title,
            v_topic_description,
            v_topic_content,
            v_topic_sequence,
            v_progress_weight
        );

        SET v_counter = v_counter + 1;
    END WHILE;

    COMMIT;

    -- Return success result
    SELECT 
        v_module_id AS module_id,
        'Course content added successfully' AS message,
        v_topic_count AS topics_added,
        200 AS status_code;

END //

DELIMITER ;

DELIMITER //
CALL sp_add_course_content(
  3001,
  'Triggers in SQL',
  'Learn about MySQL triggers.',
  1,
  JSON_ARRAY(
    JSON_OBJECT('title','Before Insert Trigger','description','Before insert logic','content','CREATE TRIGGER ...','sequence_number',1,'progress_weight',1),
    JSON_OBJECT('title','After Delete Trigger','description','After delete logic','content','AFTER DELETE ...','sequence_number',2,'progress_weight',1)
  )
);

select * from dt_learning_topics;

