DROP PROCEDURE IF EXISTS sp_add_learning_question;
DELIMITER $$

-- Adds a user's question and answer for a specific topic under a learning program
CREATE PROCEDURE sp_add_learning_question(
    IN  in_program_tid BIGINT UNSIGNED,
    IN  in_user_tid BIGINT UNSIGNED,
    IN  in_topic_tid BIGINT UNSIGNED,
    IN  in_question JSON  
)
BEGIN
    DECLARE v_enrollment_tid BIGINT UNSIGNED;
    DECLARE v_question TEXT;
    DECLARE v_answer TEXT;
    DECLARE custom_error TEXT;
    DECLARE error_message TEXT;

    -- Exit handler for rollback on error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 error_message = MESSAGE_TEXT;
        SET custom_error = COALESCE(custom_error, error_message);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END;

    START TRANSACTION;

    -- Extract question and answer from JSON
    SET v_question = JSON_UNQUOTE(JSON_EXTRACT(in_question, '$.question'));
    SET v_answer   = JSON_UNQUOTE(JSON_EXTRACT(in_question, '$.answer'));

    -- Get enrollment ID
    SELECT tid INTO v_enrollment_tid 
    FROM dt_learning_enrollments
    WHERE user_tid = in_user_tid AND learning_program_tid = in_program_tid
    LIMIT 1;

    -- Insert into dt_learning_questions
    INSERT INTO dt_learning_questions (
        enrollment_tid,
        topic_tid,
        question,
        answer
    ) VALUES (
        v_enrollment_tid,
        in_topic_tid,
        v_question,
        v_answer
    );

    -- Return inserted question ID
    SELECT JSON_OBJECT(
        'question_id', LAST_INSERT_ID()
    ) AS data;

    COMMIT;
END $$

DELIMITER ;
