DROP PROCEDURE IF EXISTS view_eligibility_template;

DELIMITER //
CREATE PROCEDURE view_eligibility_template (IN template_id BIGINT) 
BEGIN DECLARE template_exists INT DEFAULT 0;

DECLARE custom_error VARCHAR(255) DEFAULT NULL;


DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;

SELECT
    COALESCE(
        custom_error,
        'error occured while fetching template'
    ) AS message;

END;

-- Check if template exists
IF NOT EXISTS (
    SELECT
        1
    FROM
        dt_eligibility_templates
    WHERE
        TID = template_id
) THEN
SET
    custom_error = 'Template not found';

SIGNAL SQLSTATE '45000';

END IF;


START TRANSACTION;

SELECT
    JSON_OBJECT (
        'template_id',
        et.TID,
        'template_name',
        et.name,
        'questions',
        IFNULL (
            (
                SELECT
                    JSON_ARRAYAGG (
                        JSON_OBJECT (
                            'question',
                            eq.question,
                            'deciding_answer',
                            eq.deciding_answer,
                            'sequence_number',
                            eq.sequence_number
                        )
                    )
                FROM
                    dt_eligibility_questions eq
                WHERE
                    eq.template_tid = et.TID
                ORDER BY
                    eq.sequence_number
            ),
            JSON_ARRAY ()
        )
    ) AS eligibility_template
FROM
    dt_eligibility_templates et
WHERE
    et.TID = template_id;

COMMIT;

END //
DELIMITER ;

