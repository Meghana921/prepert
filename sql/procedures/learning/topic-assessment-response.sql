DROP PROCEDURE IF EXISTS evaluate_assessment;
DELIMITER //
CREATE PROCEDURE evaluate_assessment(
    IN assessment_id BIGINT UNSIGNED,
    IN user_id BIGINT UNSIGNED,
    IN responses_json JSON
)
BEGIN
    DECLARE total_score INT DEFAULT 0;
    DECLARE total_ques INT DEFAULT 0;
    DECLARE questions_json JSON;

    SELECT total_questions, gpt_questions_answers 
    INTO total_ques, questions_json
    FROM dt_topic_assessments
    WHERE tid =assessment_id;
    
 
    SET total_score = (
        SELECT SUM(
            CASE WHEN (
                SELECT JSON_EXTRACT(questions_json, CONCAT('$[', idx, '].correct_answer'))
                FROM JSON_TABLE(
                    CONCAT('[', REPEAT('0,', JSON_LENGTH(questions_json)-1), '0]'),
                    '$[*]' COLUMNS(idx FOR ORDINALITY)
                ) AS indexes
                WHERE JSON_EXTRACT(questions_json, CONCAT('$[', idx-1, '].question_id')) = 
                      JSON_EXTRACT(responses_json, CONCAT('$[', idx-1, '].question_id'))
                LIMIT 1
            ) = JSON_EXTRACT(responses_json, CONCAT('$[', idx-1, '].selected_option'))
            THEN 1 ELSE 0 END
        )
        FROM JSON_TABLE(
            CONCAT('[', REPEAT('0,', JSON_LENGTH(questions_json)-1), '0]'),
            '$[*]' COLUMNS(idx FOR ORDINALITY)
        ) AS indexes
    );
    

    UPDATE dt_topic_assessments
    SET 
        user_tid = user_id,
        user_responses = responses_json,
        total_score = total_score,
        taken_at = CURRENT_TIMESTAMP
    WHERE tid = assessment_id;
    

    SELECT CONCAT(total_score, '/', total_ques) AS score;
END //
DELIMITER ;

