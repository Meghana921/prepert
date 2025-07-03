DROP PROCEDURE IF EXISTS view_eligibility_template;
DELIMITER //

CREATE PROCEDURE view_eligibility_template(IN template_id BIGINT) 
BEGIN 
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN 
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'Error occurred while fetching template')
        ) AS data;
    END;

    -- Check if template exists
    IF NOT EXISTS (
        SELECT 1 FROM dt_eligibility_templates WHERE tid = template_id
    ) THEN
        SET custom_error = 'Template not found';
        SIGNAL SQLSTATE '45000';
    END IF;

    -- Return structured data
    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', JSON_OBJECT(
            'template_id', et.tid,
            'template_name', et.name,
            'questions', IFNULL(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'question', q.question,
                            'deciding_answer', q.deciding_answer,
                            'sequence_number', q.sequence_number
                        )
                        ORDER BY q.sequence_number
                    )
                    FROM dt_eligibility_questions q
                    WHERE q.template_tid = et.tid
                ),
                JSON_ARRAY()
            )
        )
    ) AS data
    FROM dt_eligibility_templates et
    WHERE et.tid = template_id;
END //
DELIMITER ;
