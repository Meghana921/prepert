DROP PROCEDURE IF EXISTS view_program;
DELIMITER //

CREATE PROCEDURE view_program(
    IN program_id BIGINT
) 
BEGIN 
    DECLARE program_exists INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SET custom_error = COALESCE(custom_error, 'Error fetching program details');
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = custom_error;
    END;

    -- Check if program exists and belongs to the creator
   IF NOT EXISTS ( SELECT 1 
    FROM dt_learning_programs
    WHERE tid = program_id ) 
    THEN
        SET custom_error = 'Program not found!';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = custom_error;
    END IF;

    -- Return program info with templates and invitees
    SELECT
        JSON_OBJECT(
                'program_id', lp.tid,
                'title', lp.title,
                'description', lp.description,
                'creator_id', lp.creator_tid,
                'difficulty_level', lp.difficulty_level,
                'image_path', lp.image_path,
                'price', lp.price,
                'access_period_months', lp.access_period_months,
                'available_slots', lp.available_slots,
                'campus_hiring', lp.campus_hiring,
                'sponsored', lp.sponsored,
                'minimum_score', lp.minimum_score,
                'experience_from', lp.experience_from,
                'experience_to', lp.experience_to,
                'locations', lp.locations,
                'employer_name', lp.employer_name,
                'regret_message', lp.regret_message,
                'eligibility_template', (
                    SELECT et.name 
                    FROM dt_eligibility_templates et 
                    WHERE et.tid = lp.eligibility_template_tid 
                    LIMIT 1
                ),
                'invite_template', (
                    SELECT it.name 
                    FROM dt_invite_templates it 
                    WHERE it.tid = lp.invite_template_tid 
                    LIMIT 1
                ),
                'invitees', COALESCE(
                    (
                        SELECT JSON_ARRAYAGG(
                            JSON_OBJECT('name', i.name, 'email', i.email)
                        ) 
                        FROM dt_invitees i
                        WHERE i.learning_program_tid = lp.tid
                    ), 
                    JSON_ARRAY()
                )
            )
        AS data
    FROM dt_learning_programs lp
    WHERE lp.tid = program_id;

END //
DELIMITER ;
