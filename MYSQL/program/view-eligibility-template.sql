DROP PROCEDURE IF EXISTS view_eligibility_template;
DELIMITER $$
CREATE PROCEDURE view_eligibility_template(IN template_id BIGINT)
BEGIN 
    DECLARE template_exists INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;
    
    -- Declare exit handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
         SELECT COALESCE(custom_error, 'error occured while fetching template') AS error;
    END;

    -- Check if template exists
    SELECT COUNT(*) INTO template_exists 
    FROM dt_eligibility_templates 
    WHERE TID = template_id;
    
    IF template_exists = 0 THEN
        SET custom_error = 'Template not found';
        SIGNAL SQLSTATE '45000';
    ELSE
        -- Start transaction (for atomic operation)
        START TRANSACTION;
        
        -- Return template with questions as JSON array
        SELECT JSON_OBJECT(
            'template_id', et.TID,
            'template_name', et.name,
            'questions', IFNULL(
                (SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'question', eq.question,
                        'deciding_answer', eq.deciding_answer,
                        'sequence_number', eq.sequence_number
                    )
                )
                FROM dt_eligibility_questions eq
                WHERE eq.template_tid = et.TID
                ORDER BY eq.sequence_number),
                JSON_ARRAY()
            )
        ) AS eligibility_template
        FROM dt_eligibility_templates et
        WHERE et.TID = template_id;
        
        COMMIT;
    END IF;
END $$
DELIMITER ;

call view_eligibility_template(17);