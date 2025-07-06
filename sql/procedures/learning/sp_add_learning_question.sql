DROP PROCEDURE IF EXISTS sp_add_learning_question;
DELIMITER $$

CREATE PROCEDURE sp_add_learning_question(
    IN  p_program_tid BIGINT UNSIGNED,
    IN  p_user_tid BIGINT UNSIGNED,
    IN  p_topic_tid      BIGINT UNSIGNED,
    IN  p_question       JSON
)
BEGIN
    DECLARE v_enrollment_tid BIGINT UNSIGNED;
    DECLARE custom_error VARCHAR(255);

  SELECT tid INTO v_enrollment_tid FROM  dt_learning_enrollments
  WHERE user_tid=p_user_tid AND learning_program_tid= p_program_tid;
    
    -- Insert question
    INSERT INTO dt_learning_questions (
        enrollment_tid,
        topic_tid,
        question,
        asked_at
    ) VALUES (
        v_enrollment_tid,
        p_topic_tid,
        p_question,
        NOW()
    );
    COMMIT;

    SELECT  JSON_OBJECT(
            'question_id',LAST_INSERT_ID()
        
    ) AS data;
END $$

DELIMITER ;
