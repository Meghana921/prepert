DROP PROCEDURE IF EXISTS view_program;
DELIMITER $$

CREATE PROCEDURE view_program(IN creator_id BIGINT, IN program_id BIGINT)
BEGIN
    DECLARE program_exists INT DEFAULT 0;
    DECLARE custom_error VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT JSON_OBJECT('error', COALESCE(custom_error, 'Error fetching program details')) AS result;
    END;

    START TRANSACTION;

    -- Verify program exists and belongs to creator
    SELECT COUNT(*) INTO program_exists
    FROM dt_learning_programs
    WHERE tid = program_id AND creator_tid = creator_id;
    
    IF program_exists = 0 THEN
        SET custom_error = 'Program not found or access denied';
        SIGNAL SQLSTATE '45000';
    END IF;

    -- Get program data with template names (without timestamps)
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
            'eligibility_template', IFNULL(
                (SELECT et.name 
                 FROM dt_eligibility_templates et 
                 WHERE et.tid = lp.eligibility_template_tid),
                NULL
            ),
            'invite_template', IFNULL(
                (SELECT it.name 
                 FROM dt_invite_templates it 
                 WHERE it.tid = lp.invite_template_tid),
                NULL
            )
        ) AS program_data
    FROM 
        dt_learning_programs lp
    WHERE 
        lp.tid = program_id;

    COMMIT;
END $$
DELIMITER ;

call view_program(1,4);