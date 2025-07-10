-- Event scheduler runs everyday and updates status as expires
DROP EVENT IF EXISTS update_status_daily;
DELIMITER //
CREATE EVENT update_status_daily
ON SCHEDULE EVERY 1 DAY
STARTS current_date+INTERVAL 1 DAY
DO
BEGIN 
UPDATE dt_learning_enrollments
  SET status = '3' -- 3 expired
  WHERE expires_on <= CURDATE()
  AND status != '3'; 
UPDATE dt_invitees i
JOIN dt_learning_programs l ON i.learning_program_tid = l.tid
SET status = '2'
WHERE status = '0'; -- updates when status is invited
END //
DELIMITER ;

