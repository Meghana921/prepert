DROP PROCEDURE IF EXISTS sp_add_course_content;
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
    DECLARE custom_error VARCHAR(255);

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'Database error occurred while adding course content')
        ) AS data;
    END;

    START TRANSACTION;

    -- Check for duplicate module
    SELECT COUNT(*) INTO v_duplicate_module
    FROM dt_learning_modules
    WHERE learning_program_tid = p_learning_program_tid
      AND title = p_module_title;

    IF v_duplicate_module > 0 THEN
        SET custom_error = 'Duplicate module title under this program. Not inserted.';
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', custom_error
        ) AS data;
        LEAVE sp_block;
    END IF;

    -- Insert module
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

    -- Count and insert topics
    SET v_topic_count = JSON_LENGTH(p_topics);

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

    -- JSON success response
    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', JSON_OBJECT(
            'module_id', v_module_id,
            'module_title', p_module_title,
            'topics_added', v_topic_count
        )
    ) AS data;
END //
DELIMITER ;
