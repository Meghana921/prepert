DELIMITER $$

CREATE PROCEDURE sp_add_learning_question(
    IN  p_enrollment_tid BIGINT UNSIGNED,
    IN  p_topic_tid      BIGINT UNSIGNED,
    IN  p_question       JSON
)
BEGIN
    DECLARE v_question_id BIGINT UNSIGNED;
    DECLARE v_status_code INT DEFAULT 200;
    DECLARE v_message VARCHAR(255) DEFAULT 'Question added successfully';
    DECLARE v_enrollment_exists INT DEFAULT 0;
    DECLARE v_topic_exists      INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET v_status_code = 500;
        SET v_message     = 'Database error occurred while adding question';
        SELECT NULL AS question_id, v_status_code AS status_code, v_message AS message;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validate enrollment exists
    SELECT COUNT(*) INTO v_enrollment_exists
    FROM dt_learning_enrollments
    WHERE tid = p_enrollment_tid;

    IF v_enrollment_exists = 0 THEN
        SET v_status_code = 404;
        SET v_message     = 'Enrollment not found';
        ROLLBACK;
        SELECT NULL AS question_id, v_status_code AS status_code, v_message AS message;
        LEAVE BEGIN;
    END IF;

    -- Validate topic exists
    SELECT COUNT(*) INTO v_topic_exists
    FROM dt_learning_topics
    WHERE tid = p_topic_tid;

    IF v_topic_exists = 0 THEN
        SET v_status_code = 404;
        SET v_message     = 'Topic not found';
        ROLLBACK;
        SELECT NULL AS question_id, v_status_code AS status_code, v_message AS message;
        LEAVE BEGIN;
    END IF;

    -- Insert question
    INSERT INTO dt_learning_questions (
        enrollment_tid,
        topic_tid,
        question,
        asked_at
    ) VALUES (
        p_enrollment_tid,
        p_topic_tid,
        p_question,
        NOW()
    );

    SET v_question_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_question_id AS question_id, v_status_code AS status_code, v_message AS message;
END$$

DELIMITER ;

SET @question_id = NULL;
SET @status_code = NULL;
SET @message = NULL;

CALL sp_add_learning_question(
  6001,
  5001,
  JSON_OBJECT('question_text','How do AFTER triggers differ from BEFORE triggers?','type','text')
);

SELECT @question_id, @status_code, @message;

