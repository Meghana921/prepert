DROP PROCEDURE IF EXISTS view_inviataions;
DELIMITER //

CREATE PROCEDURE view_inviataions(
  IN in_user_id BIGINT UNSIGNED 
)
BEGIN
  DECLARE user_email VARCHAR(255);

  -- Get the email address of the user from dt_users table
  SELECT email INTO user_email
    FROM dt_users
   WHERE tid = in_user_id;

  -- Fetch all the programs (Learning, Interview, and Screening) where the user is invited,
  SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
      'program_tid', p.tid,
      'program_type', p.program_type,
      'title', p.title,
      'description', p.description,
      'invite_tid', i.tid,
      'invitation_status', CASE 
        WHEN i.status = '0' THEN 'invited'
        WHEN i.status = '1' THEN 'accepted'
        WHEN i.status = '2' THEN 'declined'
        WHEN i.status = '3' THEN 'enrolled'
        ELSE NULL
      END,
      -- Embed sponsorship details as a nested JSON object
      'sponsorship', (
        SELECT JSON_OBJECT(
          'is_sponsored', ps.tid IS NOT NULL,
          'available_slots', IFNULL(ps.seats_allocated, 0) - IFNULL(ps.seats_used, 0),
          'eligibility_test_required', p.eligibility_template_tid IS NOT NULL,
          'message', CASE
            WHEN ps.tid IS NOT NULL
                 AND IFNULL(ps.seats_allocated, 0) - IFNULL(ps.seats_used, 0) <= 0
              THEN 'No sponsored seats available'
            WHEN ps.tid IS NOT NULL
                 AND p.eligibility_template_tid IS NOT NULL
              THEN 'Eligibility test required for sponsored enrollment'
            WHEN ps.tid IS NOT NULL
              THEN 'Sponsored seats available'
            ELSE 'Program is not sponsored'
          END
        )
        FROM dt_learning_programs lp
        LEFT JOIN dt_program_sponsorships ps
          ON lp.tid = ps.learning_program_tid
        WHERE lp.tid = p.tid
        LIMIT 1
      )
    )
  ) AS invitations
  FROM (
    -- Union of all programs (Learning, Interview, Screening) with common structure
    SELECT tid, '1' AS program_type, title, description, eligibility_template_tid
      FROM dt_learning_programs
     WHERE deleted_at IS NULL
       AND creator_tid IS NOT NULL

    UNION ALL

    SELECT tid, '2' AS program_type, title, description, NULL
      FROM dt_interview_programs
     WHERE creator_tid IS NOT NULL

    UNION ALL

    SELECT tid, '3' AS program_type, title, description, NULL
      FROM dt_screening_programs
     WHERE creator_tid IS NOT NULL
  ) AS p

  -- Join with dt_invitees to filter programs the user is invited to based on email
  JOIN dt_invitees AS i
    ON i.program_tid = p.tid
   AND i.program_type = p.program_type
   AND i.email = user_email
   AND i.email_status = "1"; 

END //
DELIMITER ;
