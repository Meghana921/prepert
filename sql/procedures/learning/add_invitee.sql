DROP PROCEDURE IF EXISTS add_invitees;
DELIMITER //

CREATE PROCEDURE add_invitees(
    IN in_program_type ENUM('1','2','3'),   -- 1: learning, 2: interview, 3: screening
    IN in_program_tid BIGINT,             
    IN in_request_id CHAR(36),             -- UUID for tracking bulk request
    IN in_invitees_json JSON               -- JSON array of invitee objects: [{ name, email }]
)
BEGIN    
    -- Start a database transaction
    START TRANSACTION;

    -- Insert invitees from JSON, skipping those who are already enrolled in the program
    INSERT INTO dt_invitees (
        program_type, program_tid, name, email, request_id
    )
    SELECT
        in_program_type,
        in_program_tid,
        jt.name,
        jt.email,
        in_request_id
    FROM JSON_TABLE(
        in_invitees_json,
        '$[*]' COLUMNS (
            name VARCHAR(100) PATH '$.name',
            email VARCHAR(255) PATH '$.email'
        )
    ) AS jt
    WHERE NOT EXISTS (
        SELECT 1 FROM dt_invitees di
        WHERE di.program_type = in_program_type
          AND di.program_tid = in_program_tid
          AND di.email = jt.email COLLATE utf8mb4_0900_ai_ci
          AND di.status = '1'  -- Skip if already enrolled
    );

    -- Return invitee data and email template for email sending
    IF in_program_type = '1' THEN
        -- Learning program
        SELECT JSON_ARRAYAGG(JSON_OBJECT(
            'invite_tid', i.tid,
            'program_id', lp.tid,
            'program_title', lp.title,
            'program_code', lp.program_code,
            'subject', it.subject,
            'body', it.body,
            'email', i.email,
            'name', i.name
        )) AS data
        FROM dt_invitees i
        JOIN dt_learning_programs lp ON lp.tid = i.program_tid
        JOIN dt_invite_templates it ON it.tid = lp.invite_template_tid
        WHERE i.request_id = in_request_id;

    ELSEIF in_program_type = '2' THEN
        -- Interview program
        SELECT JSON_ARRAYAGG(JSON_OBJECT(
            'invite_tid', i.tid,
            'program_tid', ip.tid,
            'program_title', ip.title,
            'subject', it.subject,
            'body', it.body,
            'email', i.email,
            'name', i.name
        )) AS data
        FROM dt_invitees i
        JOIN dt_interview_programs ip ON ip.tid = i.program_tid
        JOIN dt_invite_templates it ON it.tid = ip.invite_template_tid
        WHERE i.request_id = in_request_id;

    ELSEIF in_program_type = '3' THEN
        -- Screening program
        SELECT JSON_ARRAYAGG(JSON_OBJECT(
            'invite_tid', i.tid,
            'program_tid', sp.tid,
            'program_title', sp.title,
            'subject', it.subject,
            'body', it.body,
            'email', i.email,
            'name', i.name
        )) AS data
        FROM dt_invitees i
        JOIN dt_screening_programs sp ON sp.tid = i.program_tid
        JOIN dt_invite_templates it ON it.tid = sp.invite_template_tid
        WHERE i.request_id = in_request_id;
    END IF;

    -- Commit the transaction 
    COMMIT;
END //
DELIMITER ;
