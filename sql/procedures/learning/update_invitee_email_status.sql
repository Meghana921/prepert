DROP PROCEDURE IF EXISTS update_invitee_email_status;

DELIMITER //

CREATE PROCEDURE update_invitee_email_status(
    IN updates_json JSON  -- JSON array of invitee IDs and their email statuses
)
BEGIN
    -- Update email status, status flag, and invite_sent_at timestamp
    -- for each invitee entry present in the input JSON
    UPDATE dt_invitees d
    JOIN JSON_TABLE(
        updates_json,
        '$[*]' COLUMNS(
            id BIGINT UNSIGNED PATH '$.id',         -- Invitee ID
            status CHAR(1) PATH '$.status'          -- New email status ('1' for sent, '2' for failed)
        )
    ) js ON d.tid = js.id
    SET
        d.email_status = js.status,                                 -- Set new email status
        d.status = "0",                                              -- Reset general status to 0
        d.invite_sent_at = IF(js.status = '1', CURRENT_TIMESTAMP(), d.invite_sent_at);  
END //

DELIMITER ;
