DROP PROCEDURE IF EXISTS sp_edit_course_content;
DELIMITER $$

CREATE PROCEDURE sp_edit_course_content(
    IN p_content_type ENUM('module', 'topic'),
    IN p_content_id BIGINT UNSIGNED,
    IN p_content_json JSON,
    IN p_learning_program_tid BIGINT UNSIGNED
)
sp_block: BEGIN
    DECLARE v_module_exists INT DEFAULT 0;
    DECLARE v_topic_exists INT DEFAULT 0;
    DECLARE v_program_match INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'An error occurred while updating content')
        ) AS data;
    END;

    START TRANSACTION;

    IF p_content_type = 'module' THEN
        SELECT COUNT(*) INTO v_module_exists
        FROM dt_learning_modules
        WHERE tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_modules
        WHERE tid = p_content_id AND learning_program_tid = p_learning_program_tid;

        IF v_module_exists = 0 THEN
            SET custom_error = 'Module not found';
            SIGNAL SQLSTATE '45000';
        END IF;

        IF v_program_match = 0 THEN
            SET custom_error = 'Module does not belong to the specified program';
            SIGNAL SQLSTATE '45000';
        END IF;

        UPDATE dt_learning_modules
        SET 
            title           = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.title')), title),
            description     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.description')), description),
            sequence_number = COALESCE(JSON_EXTRACT(p_content_json, '$.sequence_number'), sequence_number),
            updated_at      = NOW()
        WHERE tid = p_content_id;

        COMMIT;

        SELECT JSON_OBJECT(
            'status', TRUE,
            'data', JSON_OBJECT(
                'content_type', 'module',
                'content_id', p_content_id,
                'message', 'Module updated successfully'
            )
        ) AS data;

    ELSEIF p_content_type = 'topic' THEN
        SELECT COUNT(*) INTO v_topic_exists
        FROM dt_learning_topics t
        JOIN dt_learning_modules m ON t.module_tid = m.tid
        WHERE t.tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_topics t
        JOIN dt_learning_modules m ON t.module_tid = m.tid
        WHERE t.tid = p_content_id AND m.learning_program_tid = p_learning_program_tid;

        IF v_topic_exists = 0 THEN
            SET custom_error = 'Topic not found';
            SIGNAL SQLSTATE '45000';
        END IF;

        IF v_program_match = 0 THEN
            SET custom_error = 'Topic does not belong to the specified program';
            SIGNAL SQLSTATE '45000';
        END IF;

        UPDATE dt_learning_topics
        SET 
            title           = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.title')), title),
            description     = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.description')), description),
            content         = COALESCE(JSON_UNQUOTE(JSON_EXTRACT(p_content_json, '$.content')), content),
            sequence_number = COALESCE(JSON_EXTRACT(p_content_json, '$.sequence_number'), sequence_number),
            progress_weight = COALESCE(JSON_EXTRACT(p_content_json, '$.progress_weight'), progress_weight),
            updated_at      = NOW()
        WHERE tid = p_content_id;

        COMMIT;

        SELECT JSON_OBJECT(
            'status', TRUE,
            'data', JSON_OBJECT(
                'content_type', 'topic',
                'content_id', p_content_id,
                'message', 'Topic updated successfully'
            )
        ) AS data;

    ELSE
        SET custom_error = 'Invalid content type. Use module or topic.';
        SIGNAL SQLSTATE '45000';
    END IF;

END $$

DELIMITER ;
