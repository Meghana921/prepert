
DELIMITER //

CREATE PROCEDURE sp_delete_course_content(
    IN p_content_type ENUM('module', 'topic'),
    IN p_content_id BIGINT UNSIGNED,
    IN p_learning_program_tid BIGINT UNSIGNED
)
BEGIN
    DECLARE v_content_exists INT DEFAULT 0;
    DECLARE v_program_match INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_content_type = 'module' THEN
        -- Check if module exists and belongs to the program
        SELECT COUNT(*) INTO v_content_exists 
        FROM dt_learning_modules 
        WHERE tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_modules 
        WHERE tid = p_content_id AND learning_program_tid = p_learning_program_tid;

        IF v_content_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Module not found';
        END IF;

        IF v_program_match = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Module does not belong to this program';
        END IF;

        -- Delete all topics in the module first
        DELETE FROM dt_learning_topics 
        WHERE module_tid = p_content_id;

        -- Delete learning progress for topics in this module
        DELETE lp FROM dt_learning_progress lp
        JOIN dt_learning_topics lt ON lp.topic_tid = lt.tid
        WHERE lt.module_tid = p_content_id;

        -- Delete the module
        DELETE FROM dt_learning_modules 
        WHERE tid = p_content_id;

        SELECT 
            'Module and all its topics deleted successfully' AS message,
            ROW_COUNT() AS affected_rows;

    ELSEIF p_content_type = 'topic' THEN
        -- Check if topic exists and belongs to a module of the program
        SELECT COUNT(*) INTO v_content_exists 
        FROM dt_learning_topics lt
        JOIN dt_learning_modules lm ON lt.module_tid = lm.tid
        WHERE lt.tid = p_content_id;

        SELECT COUNT(*) INTO v_program_match
        FROM dt_learning_topics lt
        JOIN dt_learning_modules lm ON lt.module_tid = lm.tid
        WHERE lt.tid = p_content_id AND lm.learning_program_tid = p_learning_program_tid;

        IF v_content_exists = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Topic not found';
        END IF;

        IF v_program_match = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Topic does not belong to this program';
        END IF;

        -- Delete learning progress for this topic
        DELETE FROM dt_learning_progress 
        WHERE topic_tid = p_content_id;

        -- Delete learning questions for this topic
        DELETE FROM dt_learning_questions 
        WHERE topic_tid = p_content_id;

        -- Delete the topic
        DELETE FROM dt_learning_topics 
        WHERE tid = p_content_id;

        SELECT 
            'Topic deleted successfully' AS message,
            ROW_COUNT() AS affected_rows;

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid content type. Use "module" or "topic"';
    END IF;

    COMMIT;
END //

DELIMITER ;
CALL sp_add_course_content(
  3001,
  'Indexes in SQL',
  'Learn about indexing strategies.',
  6,
  JSON_ARRAY(
    JSON_OBJECT('title','Index Basics','description','Intro to indexes','content','CREATE INDEX ...','sequence_number',1,'progress_weight',1),
    JSON_OBJECT('title','Unique Index','description','Ensuring uniqueness','content','CREATE UNIQUE INDEX ...','sequence_number',2,'progress_weight',2)
  )
);
CALL sp_delete_course_content('topic', 20, 3001);

call sp_view_all_lms_data_flat();
