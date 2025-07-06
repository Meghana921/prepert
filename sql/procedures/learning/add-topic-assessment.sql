DROP PROCEDURE IF EXISTS add_topic_assessment;

DELIMITER //

CREATE PROCEDURE add_topic_assessment (
    IN in_user_tid BIGINT UNSIGNED,
    IN in_topic_tid BIGINT UNSIGNED,
    IN in_questions_json JSON
)
BEGIN
    DECLARE assessment_id BIGINT UNSIGNED;
    START TRANSACTION;

    -- Insert topic assessment
    INSERT INTO dt_topic_assessments (
        user_tid,
        topic_tid,
        gpt_questions_answers,
        total_questions
    ) VALUES (
        in_user_tid,
        in_topic_tid,
        in_questions_json,
        JSON_LENGTH(in_questions_json)
    );

    SET assessment_id = LAST_INSERT_ID();

    -- Extract question list from inserted JSON and return structured response
    SELECT  JSON_OBJECT(
            'assessment_id', a.tid,
            'topic_id', a.topic_tid,
            'questions', COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'sequence_number', q.sequence_number,
                            'question', q.question,
                            'options', q.options
                        )
                    )
                    FROM JSON_TABLE(
                        a.gpt_questions_answers,
                        '$[*]' COLUMNS (
                            sequence_number VARCHAR(50) PATH '$.sequence_number',
                            question TEXT PATH '$.question',
                            options JSON PATH '$.options'
                        )
                    ) AS q
                ),
                JSON_ARRAY()
            )
        
    ) AS data
    FROM dt_topic_assessments a
    WHERE a.tid = assessment_id;
   COMMIT;
END //

DELIMITER ;
