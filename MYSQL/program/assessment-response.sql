DROP PROCEDURE IF EXISTS evaluate_assessment;
DELIMITER $$
CREATE PROCEDURE evaluate_assessment(
    IN p_assessment_tid BIGINT UNSIGNED,
    IN p_user_tid BIGINT UNSIGNED,
    IN p_responses_json JSON
)
BEGIN
    DECLARE v_total_score INT DEFAULT 0;
    DECLARE v_total_questions INT DEFAULT 0;
    DECLARE v_questions_json JSON;

    SELECT total_questions, gpt_questions_answers 
    INTO v_total_questions, v_questions_json
    FROM dt_topic_assessments
    WHERE tid = p_assessment_tid;
    
 
    SET v_total_score = (
        SELECT SUM(
            CASE WHEN (
                SELECT JSON_EXTRACT(v_questions_json, CONCAT('$[', idx, '].correct_answer'))
                FROM JSON_TABLE(
                    CONCAT('[', REPEAT('0,', JSON_LENGTH(v_questions_json)-1), '0]'),
                    '$[*]' COLUMNS(idx FOR ORDINALITY)
                ) AS indexes
                WHERE JSON_EXTRACT(v_questions_json, CONCAT('$[', idx-1, '].question_id')) = 
                      JSON_EXTRACT(p_responses_json, CONCAT('$[', idx-1, '].question_id'))
                LIMIT 1
            ) = JSON_EXTRACT(p_responses_json, CONCAT('$[', idx-1, '].selected_option'))
            THEN 1 ELSE 0 END
        )
        FROM JSON_TABLE(
            CONCAT('[', REPEAT('0,', JSON_LENGTH(v_questions_json)-1), '0]'),
            '$[*]' COLUMNS(idx FOR ORDINALITY)
        ) AS indexes
    );
    

    UPDATE dt_topic_assessments
    SET 
        user_tid = p_user_tid,
        user_responses = p_responses_json,
        total_score = v_total_score,
        taken_at = CURRENT_TIMESTAMP
    WHERE tid = p_assessment_tid;
    

    SELECT CONCAT(v_total_score, '/', v_total_questions) AS score;
END $$
DELIMITER ;


CALL evaluate_assessment(2, 123, 
    JSON_ARRAY(
        JSON_OBJECT("question_id", 101, "selected_option", 1),
        JSON_OBJECT("question_id", 102, "selected_option", 2)
    )
);
