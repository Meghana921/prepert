DELIMITER //
CREATE PROCEDURE add_and_show_questions(
    IN p_user_tid BIGINT UNSIGNED,
    IN p_topic_tid BIGINT UNSIGNED,
    IN p_questions_json JSON
)
BEGIN
    DECLARE v_assessment_tid BIGINT UNSIGNED;
    
    -- Validate JSON input
    IF JSON_VALID(p_questions_json) = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid JSON format provided';
    END IF;
    
    -- Add new assessment
    INSERT INTO dt_topic_assessments (
        user_tid,
        topic_tid,
        gpt_questions_answers,
        total_questions,
        taken_at
    ) VALUES (
        p_user_tid,
        p_topic_tid,
        p_questions_json,
        JSON_LENGTH(p_questions_json),
        CURRENT_TIMESTAMP
    );
    
    -- Get the newly created assessment TID
    SET v_assessment_tid = LAST_INSERT_ID();
    
    -- Extract and return only questions and options with TIDs
    SELECT 
        a.tid AS assessment_tid,
        JSON_ARRAYAGG(
            JSON_OBJECT(
                'question_tid', q.tid,
                'question', q.question,
                'options', q.options
            )
        ) AS questions
    FROM dt_topic_assessments a,
    JSON_TABLE(
        a.gpt_questions_answers,
        '$[*]' COLUMNS(
            tid BIGINT UNSIGNED PATH '$.question_id',
            question TEXT PATH '$.question',
            options JSON PATH '$.options'
        )
    ) AS q
    WHERE a.tid = v_assessment_tid
    GROUP BY a.tid;
END //
DELIMITER ;
CALL add_and_show_questions(
    123,  -- User TID
    5,    -- Topic TID
    '[{
        "question_id": 101,
        "question": "What is 2+2?",
        "options": ["3", "4", "5"],
        "correct_answer": 1,
        "marks": 1
    },
    {
        "question_id": 102,
        "question": "Capital of France?",
        "options": ["London", "Paris", "Berlin"],
        "correct_answer": 1,
        "marks": 1
    }]'
);
