DROP PROCEDURE IF EXISTS list_eligibility_template;
DELIMITER //

CREATE PROCEDURE list_eligibility_template(IN creator_id BIGINT)
BEGIN
    DECLARE custom_error VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', COALESCE(custom_error, 'Error while listing eligibility templates')
        ) AS data;
    END;

    -- Return JSON response with all templates created by the user
    SELECT JSON_OBJECT(
        'status', TRUE,
        'data', COALESCE(
            (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'template_id', t.tid,
                        'template_name', t.name
                    )
                )
                FROM dt_eligibility_templates t
                WHERE t.creator_tid = creator_id
            ),
            JSON_ARRAY()
        )
    ) AS data;

END //

DELIMITER ;
