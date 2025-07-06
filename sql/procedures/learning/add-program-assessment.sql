DROP PROCEDURE IF EXISTS add_program_assessment;

DELIMITER //

CREATE PROCEDURE add_program_assessment (
    IN in_program_id BIGINT UNSIGNED,
    IN in_title VARCHAR(100),
    IN in_description TEXT,
    IN in_question_count SMALLINT UNSIGNED,
    IN in_passing_score TINYINT UNSIGNED,
    IN in_questions JSON
)
BEGIN
    DECLARE assessment_id BIGINT UNSIGNED;
    DECLARE questions_added INT UNSIGNED DEFAULT 0;
    DECLARE custom_error VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
            SET custom_error =  COALESCE(custom_error, 'An error occurred during assessment creation');
            SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
    END;

    START TRANSACTION;

    -- Check if the program exists
    IF NOT EXISTS (
        SELECT 1 FROM dt_learning_programs WHERE tid = in_program_id
    ) THEN
        SET custom_error = CONCAT('Learning program with ID ', in_program_id, ' does not exist');
       SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
    END IF;

    -- Check if assessment already exists
    IF EXISTS (
        SELECT 1 FROM dt_learning_assessments WHERE learning_program_tid = in_program_id
    ) THEN
        SET custom_error = 'Assessment for this program has already been created. You can access and update it if necessary';
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
    END IF;

    -- Insert into dt_learning_assessments
    INSERT INTO dt_learning_assessments (
        learning_program_tid,
        title,
        description,
        question_count,
        passing_score
    ) VALUES (
        in_program_id,
        in_title,
        in_description,
        in_question_count,
        in_passing_score
    );

    SET assessment_id = LAST_INSERT_ID();

    -- Insert questions if provided
    IF in_questions IS NOT NULL AND JSON_LENGTH(in_questions) > 0 THEN
        INSERT INTO dt_assessment_questions (
            assessment_tid,
            question,
            options,
            correct_option,
            score,
            sequence_number
            
        )
        SELECT
            assessment_id,
            question,
            options,
            correct_option,
            IFNULL(score, 1),
            sequence_number
        FROM JSON_TABLE (
            in_questions,
            '$[*]' COLUMNS (
                question TEXT PATH '$.question',
                options JSON PATH '$.options',
                correct_option INT PATH '$.correct_option',
                score INT PATH '$.score',
              sequence_number INT PATH '$.sequence_number'
            )
        ) AS questions;

        SET questions_added = ROW_COUNT();
	ELSE
    SET custom_error = 'No questions found to insert';
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT=custom_error;
    END IF;

    COMMIT;

    -- Return structured response
   SELECT JSON_OBJECT(
            'assessment_id', assessment_id,
            'total_questions', questions_added
        
    ) AS data;
END //

DELIMITER ;
