DROP PROCEDURE IF EXISTS list_all_invitations;
DELIMITER //

CREATE PROCEDURE list_all_invitations(IN in_user_id BIGINT UNSIGNED)
BEGIN
    -- First get the user's email
    DECLARE user_email VARCHAR(255);
    
    SELECT email INTO user_email FROM dt_users WHERE tid = in_user_id;
    
    -- Return only programs where the user is actually invited
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'program_tid', p.tid,
            'program_type', p.program_type,
            'title', p.title,
            'description', p.description,
            'invite_tid', i.tid,
            'invitation_status', CASE 
                WHEN i.status = '0' THEN 'invited'
                WHEN i.status = '1' THEN 'enrolled'
                WHEN i.status = '2' THEN 'expired'
                WHEN i.status = '3' THEN 'declined'
                ELSE NULL
            END
        )
    ) AS invitations
    FROM (
        SELECT 
            tid, 
            '1' AS program_type, 
            title, 
            description
        FROM dt_learning_programs
        WHERE is_deleted = FALSE 
        AND creator_tid IS NOT NULL
        
        UNION ALL
        
        SELECT 
            tid, 
            '2' AS program_type, 
            title, 
            description
        FROM dt_interview_programs
        WHERE creator_tid IS NOT NULL
        
        UNION ALL
        
        SELECT 
            tid, 
            '3' AS program_type, 
            title, 
            description
        FROM dt_screening_programs
        WHERE creator_tid IS NOT NULL
    ) p
    INNER JOIN dt_invitees i ON 
        i.program_tid = p.tid AND 
        i.program_type = p.program_type AND
        i.email = user_email
    WHERE i.status IS NOT NULL;
END //

DELIMITER ;