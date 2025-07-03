DROP PROCEDURE IF EXISTS sp_delete_course_content;
DELIMITER //

CREATE PROCEDURE sp_delete_course_content(
    IN p_content_type ENUM('module', 'topic'),
    IN p_content_id BIGINT UNSIGNED,
    IN p_learning_program_tid BIGINT UNSIGNED
)
main_block: BEGIN
    DECLARE v_content_exists INT DEFAULT 0;
    DECLARE v_program_match INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT('status', FALSE, 'message', COALESCE(custom_error, 'Database error')) AS data;
    END;

    START TRANSACTION;

    IF p_content_type = 'module' THEN

        -- Check existence and association
        SELECT COUNT(*) INTO v_content_exists 
        FROM dt_learning_modules 
        WHERE tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_modules 
        WHERE tid = p_content_id AND learning_program_tid = p_learning_program_tid;

        IF v_content_exists = 0 THEN
            SET custom_error = 'Module not found';
            SIGNAL SQLSTATE '45000';
        END IF;

        IF v_program_match = 0 THEN
            SET custom_error = 'Module does not belong to the specified program';
            SIGNAL SQLSTATE '45000';
        END IF;

        -- Delete progress and topics
        DELETE lp FROM dt_learning_progress lp
        JOIN dt_learning_topics lt ON lp.topic_tid = lt.tid
        WHERE lt.module_tid = p_content_id;

        DELETE FROM dt_learning_topics 
        WHERE module_tid = p_content_id;

        DELETE FROM dt_learning_modules 
        WHERE tid = p_content_id;

        COMMIT;

        SELECT JSON_OBJECT(
            'status', TRUE,
            'data', JSON_OBJECT(
                'deleted_type', 'module',
                'deleted_id', p_content_id,
                'message', 'Module and its associated topics deleted successfully'
            )
        ) AS data;

    ELSEIF p_content_type = 'topic' THEN

        -- Check topic existence
        SELECT COUNT(*) INTO v_content_exists 
        FROM dt_learning_topics lt
        JOIN dt_learning_modules lm ON lt.module_tid = lm.tid
        WHERE lt.tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_topics lt
        JOIN dt_learning_modules lm ON lt.module_tid = lm.tid
        WHERE lt.tid = p_content_id AND lm.learning_program_tid = p_learning_program_tid;

        IF v_content_exists = 0 THEN
            SET custom_error = 'Topic not found';
            SIGNAL SQLSTATE '45000';
        END IF;

        IF v_program_match = 0 THEN
            SET custom_error = 'Topic does not belong to the specified program';
            SIGNAL SQLSTATE '45000';
        END IF;

        -- Delete progress and questions
        DELETE FROM dt_learning_progress 
        WHERE topic_tid = p_content_id;

        DELETE FROM dt_learning_questions 
        WHERE topic_tid = p_content_id;

        DELETE FROM dt_learning_topics 
        WHERE tid = p_content_id;

        COMMIT;

        SELECT JSON_OBJECT(
            'status', TRUE,
            'data', JSON_OBJECT(
                'deleted_type', 'topic',
                'deleted_id', p_content_id,
                'message', 'Topic deleted successfully'
            )
        ) AS data;

    ELSE
        SET custom_error = 'Invalid content type. Use "module" or "topic"';
        SIGNAL SQLSTATE '45000';
    END IF;

END //
DELIMITER ;
