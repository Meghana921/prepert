DROP PROCEDURE IF EXISTS view_created_program;
DELIMITER //
CREATE PROCEDURE view_created_program(IN creator_id BIGINT)
BEGIN 
SELECT JSON_OBJECT("program_id",TID,"program_name",title) AS program_list FROM dt_learning_programs
WHERE creator_tid = creator_id
order by created_at;
END //

DELIMITER ;