DROP PROCEDURE IF EXISTS view_eligibility_template;
DELIMITER //

CREATE PROCEDURE view_eligibility_template(IN in_template_tid BIGINT)
BEGIN

    -- Return structured JSON with template and its questions
    SELECT JSON_OBJECT(
        'template_id', et.tid,
        'template_name', et.name,
        'questions', IFNULL((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'question', sub.question,
                    'deciding_answer', sub.deciding_answer,
                    'sequence_number', sub.sequence_number
                )
            )
            FROM (
                SELECT question, deciding_answer, sequence_number
                FROM dt_eligibility_questions
                WHERE template_tid = in_template_tid
                ORDER BY sequence_number
            ) AS sub
        ), JSON_ARRAY())
    ) AS data
    FROM dt_eligibility_templates et
    WHERE et.tid = in_template_tid;

END //

DELIMITER ;
call  view_eligibility_template(1);