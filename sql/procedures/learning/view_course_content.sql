DROP PROCEDURE IF EXISTS view_course_content;
DELIMITER $$

CREATE PROCEDURE view_course_content(
    IN p_learning_program_tid BIGINT UNSIGNED
)
BEGIN
    SELECT JSON_OBJECT(
        'program_id', p_learning_program_tid,
        'modules', COALESCE((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'module_id', m.tid,
                    'module_title', m.title,
                    'module_description', m.description,
                    'sequence_number', m.sequence_number,
                    'topics', COALESCE((
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT(
                                'topic_id', t.tid,
                                'topic_title', t.title,
                                'topic_description', t.description,
                                'sequence_number', t.sequence_number,
                                'progress_weight', t.progress_weight,
                                'content', t.content
                            )
                        )
                        FROM dt_learning_topics t
                        WHERE t.module_tid = m.tid
                        ORDER BY t.sequence_number
                    ), JSON_ARRAY())
                )
            )
            FROM dt_learning_modules m
            WHERE m.learning_program_tid = p_learning_program_tid
            ORDER BY m.sequence_number
        ), JSON_ARRAY())
    ) AS data;
END $$
DELIMITER ;
call view_course_content(1)