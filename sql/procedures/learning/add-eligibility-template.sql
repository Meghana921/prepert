DELIMITER //
DROP PROCEDURE IF EXISTS add_eligibility_template;
CREATE PROCEDURE add_eligibility_template (
    IN creator_id           BIGINT,
    IN template_name        VARCHAR(100),
    IN eligibility_questions JSON
)
BEGIN
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;
    DECLARE template_id BIGINT;
    DECLARE duplicate_count INT DEFAULT 0;
    DECLARE question_count INT DEFAULT 0;
    
    -- Error handler rolls back and returns JSON under alias "status"
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1 custom_error = MESSAGE_TEXT;
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'An error occurred while inserting template')
        ) AS status;
    END;
    
    START TRANSACTION;
    
    -- Input validation
    IF creator_id IS NULL OR creator_id <= 0 THEN
        SET custom_error = 'Invalid creator_id provided';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;
    
    IF template_name IS NULL OR TRIM(template_name) = '' THEN
        SET custom_error = 'Template name cannot be empty';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;
    
    IF eligibility_questions IS NULL OR JSON_LENGTH(eligibility_questions) = 0 THEN
        SET custom_error = 'At least one eligibility question is required';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;
    
    -- Check if template with same name already exists for this creator
    IF EXISTS (
        SELECT 1 
        FROM eligibility_templates 
        WHERE creator_id = creator_id 
          AND template_name = template_name
    ) THEN
        SET custom_error = CONCAT(
            template_name,
            ' – template already exists! You can view and edit it.'
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;
    
    -- Insert template
    INSERT INTO eligibility_templates (creator_id, template_name)
    VALUES (creator_id, template_name);
    
    SET template_id = LAST_INSERT_ID();
    
    -- Insert questions
    INSERT INTO eligibility_questions (
        template_id,
        question,
        deciding_answer,
        sequence_number
    )
    SELECT
        template_id,
        q.question,
        q.deciding_answer,
        q.sequence_number
    FROM JSON_TABLE(
        eligibility_questions,
        '$[*]' : COLUMNS (
            question           TEXT        PATH '$.question',
            deciding_answer    VARCHAR(3)  PATH '$.deciding_answer',
            sequence_number    INT         PATH '$.sequence_number'
        )
    ) AS q
    WHERE
        q.question IS NOT NULL
        AND TRIM(q.question) <> ''
        AND q.deciding_answer IS NOT NULL
        AND q.sequence_number IS NOT NULL;
    
    -- Check if any questions were actually inserted
    SELECT COUNT(*) INTO question_count
    FROM eligibility_questions
    WHERE template_id = template_id;
    
    IF question_count = 0 THEN
        SET custom_error = 'No valid questions were found in the provided data';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;
    
    -- Check for duplicate questions within the same template
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT question
        FROM eligibility_questions
        WHERE template_id = template_id
        GROUP BY question
        HAVING COUNT(*) > 1
    ) AS dup;
    
    IF duplicate_count > 0 THEN
        SET custom_error = 'Duplicate questions found in the template';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;
    
    COMMIT;
    
    -- Success: return JSON under alias "status"
    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', JSON_OBJECT(
            'template_id', template_id,
            'template_name', template_name
        )
    ) AS status;
END //
DELIMITER ;