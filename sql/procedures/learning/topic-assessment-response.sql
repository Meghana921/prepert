DROP PROCEDURE IF EXISTS evaluate_assessment;
DELIMITER $$

CREATE PROCEDURE evaluate_assessment(
    IN assessment_id   BIGINT UNSIGNED,
    IN user_id         BIGINT UNSIGNED,
    IN responses_json  JSON
)
BEGIN
    DECLARE total_score     INT DEFAULT 0;
    DECLARE total_questions INT DEFAULT 0;
    DECLARE correct_answer  VARCHAR(255);
    DECLARE selected_option VARCHAR(255);
    DECLARE question_id     VARCHAR(100);
    
    DECLARE question_idx INT DEFAULT 0;
    DECLARE loop_count INT;
    
    DECLARE questions_json JSON;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', 'Error occurred while evaluating assessment'
        ) AS data;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Fetch original question set
    SELECT total_questions, gpt_questions_answers 
    INTO total_questions, questions_json
    FROM dt_topic_assessments
    WHERE tid = assessment_id;

    SET loop_count = JSON_LENGTH(questions_json);
    SET question_idx = 0;

    WHILE question_idx < loop_count DO
        SET question_id = JSON_UNQUOTE(JSON_EXTRACT(questions_json, CONCAT('$[', question_idx, '].question_id')));
        SET correct_answer = JSON_UNQUOTE(JSON_EXTRACT(questions_json, CONCAT('$[', question_idx, '].correct_answer')));

        -- Find the matching selected option from user response
        SET selected_option = JSON_UNQUOTE(
            JSON_EXTRACT(
                (SELECT r.response
                 FROM JSON_TABLE(responses_json, '$[*]' COLUMNS (
                    response JSON PATH '$'
                 )) AS r
                 WHERE JSON_UNQUOTE(JSON_EXTRACT(r.response, '$.question_id')) = question_id
                 LIMIT 1
                ),
                '$.selected_option'
            )
        );

        -- Compare correct vs selected
        IF correct_answer IS NOT NULL AND selected_option IS NOT NULL AND correct_answer = selected_option THEN
            SET total_score = total_score + 1;
        END IF;

        SET question_idx = question_idx + 1;
    END WHILE;

    -- Update record
    UPDATE dt_topic_assessments
    SET 
        user_tid = user_id,
        user_responses = responses_json,
        total_score = total_score,
        taken_at = CURRENT_TIMESTAMP
    WHERE tid = assessment_id;

    COMMIT;

    -- Return JSON score
    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', JSON_OBJECT(
            'score', CONCAT(total_score, '/', total_questions)
        )
    ) AS data;

END$$
DELIMITER ;

-- {
--   "status": true,
--   "data": {
--     "score": "3/5"
--   }
-- }
