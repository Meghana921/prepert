DROP PROCEDURE IF EXISTS sp_add_learning_question;
DELIMITER $$

CREATE PROCEDURE sp_add_learning_question(
    IN  p_enrollment_tid BIGINT UNSIGNED,
    IN  p_topic_tid      BIGINT UNSIGNED,
    IN  p_question       JSON
)
main_block: BEGIN
    DECLARE v_question_id BIGINT UNSIGNED;
    DECLARE v_enrollment_exists INT DEFAULT 0;
    DECLARE v_topic_exists      INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'Database error occurred while adding question')
        ) AS data;
    END;

    START TRANSACTION;

    -- Validate enrollment
    SELECT COUNT(*) INTO v_enrollment_exists
    FROM dt_learning_enrollments
    WHERE tid = p_enrollment_tid;

    IF v_enrollment_exists = 0 THEN
        SET custom_error = 'Enrollment not found';
        ROLLBACK;
        SELECT JSON_OBJECT('status', FALSE, 'message', custom_error) AS data;
        LEAVE main_block;
    END IF;

    -- Validate topic
    SELECT COUNT(*) INTO v_topic_exists
    FROM dt_learning_topics
    WHERE tid = p_topic_tid;

    IF v_topic_exists = 0 THEN
        SET custom_error = 'Topic not found';
        ROLLBACK;
        SELECT JSON_OBJECT('status', FALSE, 'message', custom_error) AS data;
        LEAVE main_block;
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

    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', JSON_OBJECT(
            'question_id', v_question_id,
            'message', 'Question added successfully'
        )
    ) AS data;
END $$

DELIMITER ;
