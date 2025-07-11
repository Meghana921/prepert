DROP EVENT IF EXISTS update_status_daily;
DELIMITER //

CREATE EVENT update_status_daily
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN 
  -- 1. Expire learning enrollments based on expiry date
  UPDATE dt_learning_enrollments
  SET status = '3'  -- 3 = expired
  WHERE expires_on <= CURDATE()
    AND status != '3'; 

  -- 2. Expire invitees not enrolled within 10 days of invitation
  UPDATE dt_invitees
  SET status = '2'  -- 2 = expired
  WHERE status = '0'  -- still invited
    AND DATEDIFF(CURDATE(), created_at) > 10;
END //

DELIMITER ;
