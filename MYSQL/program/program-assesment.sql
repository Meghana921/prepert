DROP PROCEDURE IF EXISTS sp_process_assessment_data;
DELIMITER //

CREATE PROCEDURE add_learning_assessment(
    IN p_assessment_data JSON,
    IN p_questions_data JSON
)
BEGIN
    DECLARE assessment_id BIGINT UNSIGNED;
    DECLARE questions_added INT;
    
    -- Insert assessment data
    INSERT INTO dt_learning_assessments (
        learning_program_tid,
        title,
        description,
        question_count,
        passing_score,
        created_at,
        updated_at
    )
    SELECT 
        JSON_UNQUOTE(JSON_EXTRACT(p_assessment_data, '$.learning_program_tid')),
        JSON_UNQUOTE(JSON_EXTRACT(p_assessment_data, '$.title')),
        JSON_UNQUOTE(JSON_EXTRACT(p_assessment_data, '$.description')),
        JSON_EXTRACT(p_assessment_data, '$.question_count'),
        JSON_EXTRACT(p_assessment_data, '$.passing_score'),
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP;
    
    SET assessment_id = LAST_INSERT_ID();
    
    -- Insert questions using JSON_TABLE (MySQL 8.0+)
    INSERT INTO dt_assessment_questions (
        assessment_tid,
        question,
        options,
        correct_option,
        score,
        created_at
    )
    SELECT 
        assessment_id,
        question,
        options,
        correct_option,
        IFNULL(score, 1),
        CURRENT_TIMESTAMP
    FROM JSON_TABLE(
        p_questions_data,
        '$[*]' COLUMNS(
            question TEXT PATH '$.question',
            options JSON PATH '$.options',
            correct_option VARCHAR(50) PATH '$.correct_option',
            score SMALLINT UNSIGNED PATH '$.score'
        )
    ) AS questions;
    
    -- Get count of questions added
    SELECT COUNT(TID) INTO questions_added
    FROM dt_assessment_questions
    WHERE assessment_tid = assessment_id;
    
    -- Return JSON output
    SELECT JSON_OBJECT(
        'assessment_id', assessment_id
    ) AS result;
END //

DELIMITER ;

CALL sp_process_assessment_data(
    -- Assessment data
    JSON_OBJECT(
        'learning_program_tid', 1,
        'title', 'Basic Math Assessment',
        'description', 'Test your basic math skills',
        'question_count', 3,
        'passing_score', 70
    ),
    -- Questions data
    JSON_ARRAY(
        JSON_OBJECT(
            'question', 'What is 2 + 2?',
            'options', JSON_ARRAY('3', '4', '5', '6'),
            'correct_option', '4',
            'score', 1
        ),
        JSON_OBJECT(
            'question', 'What is 5 × 7?',
            'options', JSON_ARRAY('25', '30', '35', '40'),
            'correct_option', '35',
            'score', 1
        ),
        JSON_OBJECT(
            'question', 'What is 10 ÷ 2?',
            'options', JSON_ARRAY('2', '5', '8', '10'),
            'correct_option', '5',
            'score', 1
        )
    )
);