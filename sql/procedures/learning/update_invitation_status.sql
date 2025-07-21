DROP PROCEDURE IF EXISTS update_invitation_status;

DELIMITER //

CREATE PROCEDURE update_invitation_status(
    IN in_invite_id BIGINT,          -- ID of the invitee
    IN in_status VARCHAR(10)         -- Invitation response status: 'accepted' or other
)
BEGIN
    START TRANSACTION;

    -- Update the invitation status and set response timestamp
    UPDATE dt_invitees
    SET  
        response_at = CURRENT_TIMESTAMP(),                            -- Record the time of response
        status = CASE 
                    WHEN in_status = 'accepted' THEN '1'             -- Status 1 for accepted
                    ELSE '2'                                         -- Status 2 for rejected
                 END
    WHERE tid = in_invite_id;                                         

    COMMIT;
END //

DELIMITER ;
