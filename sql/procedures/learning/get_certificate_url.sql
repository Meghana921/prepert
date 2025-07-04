DROP PROCEDURE IF EXISTS get_certificate_url;
DELIMITER //
CREATE PROCEDURE get_certificate_url(
    IN in_enrollment_tid BIGINT
)
BEGIN
    DECLARE v_progress INT DEFAULT 0;
    DECLARE v_program_id BIGINT;
    DECLARE v_user_id BIGINT;
    DECLARE v_certificate_url VARCHAR(512);

    -- Get user_id, program_id, and progress for the enrollment
    SELECT user_tid, program_tid, progress
    INTO v_user_id, v_program_id, v_progress
    FROM dt_program_enrollments
    WHERE tid = in_enrollment_tid
    LIMIT 1;

    IF v_progress = 100 THEN
        -- Generate or fetch the certificate URL (example URL, replace with your logic)
        SET v_certificate_url = CONCAT('https://yourdomain.com/certificates/', in_enrollment_tid, '.pdf');
        SELECT JSON_OBJECT(
            'status', TRUE,
            'data', JSON_OBJECT(
                'certificate_url', v_certificate_url
            )
        ) AS data;
    ELSE
        SELECT JSON_OBJECT(
            'status', FALSE,
            'message', 'Certificate not available. Complete the program to unlock.'
        ) AS data;
    END IF;
END //
DELIMITER ; 