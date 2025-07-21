DROP PROCEDURE IF EXISTS view_course_content;
DELIMITER //

CREATE PROCEDURE view_course_content(
    IN p_learning_program_tid BIGINT UNSIGNED 
)
BEGIN
    -- Construct and return a nested JSON object containing program modules and their topics
    SELECT JSON_OBJECT(
        'program_id', p_learning_program_tid,

        -- Fetch modules associated with the learning program
        'modules', COALESCE((
            SELECT JSON_ARRAYAGG( -- Aggregate all modules into a JSON array
                JSON_OBJECT(
                    'module_id', m.tid, 
                    'module_title', m.title, 
                    'module_description', m.description, 
                    'sequence_number', m.sequence_number, 

                    -- Fetch topics associated with each module
                    'topics', COALESCE((
                        SELECT JSON_ARRAYAGG( -- Aggregate all topics into a JSON array
                            JSON_OBJECT(
                                'topic_id', t.tid, 
                                'topic_title', t.title, 
                                'topic_description', t.description, 
                                'sequence_number', t.sequence_number, 
                                'content', t.content 
                            )
                        )
                        FROM dt_learning_topics t
                        WHERE t.module_tid = m.tid 
                        ORDER BY t.sequence_number 
                    ), JSON_ARRAY()) -- If no topics found, return empty array
                )
            )
            FROM dt_learning_modules m
            WHERE m.learning_program_tid = p_learning_program_tid 
            ORDER BY m.sequence_number 
        ), JSON_ARRAY()) -- If no modules found, return empty array
    ) AS data; 
END //
DELIMITER ;
