DROP PROCEDURE IF EXISTS delete_program;
DELIMITER //

CREATE PROCEDURE delete_program(IN program_id BIGINT UNSIGNED)
BEGIN 
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  ROLLBACK;
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Delete failed';
END;
  START TRANSACTION;

  -- Temp table for topic IDs
  CREATE TEMPORARY TABLE temp_topic_ids (tid BIGINT UNSIGNED);
  INSERT INTO temp_topic_ids (tid)
  SELECT t.tid
  FROM dt_learning_topics t
  JOIN dt_learning_modules m ON t.module_tid = m.tid
  WHERE m.learning_program_tid = program_id;

  -- Delete topic-related data
  DELETE FROM dt_learning_questions
  WHERE topic_tid IN (SELECT tid FROM temp_topic_ids);

  DELETE FROM dt_topic_assessments
  WHERE topic_tid IN (SELECT tid FROM temp_topic_ids);

  DELETE FROM dt_learning_progress
  WHERE topic_tid IN (SELECT tid FROM temp_topic_ids);

  DELETE FROM dt_learning_topics
  WHERE tid IN (SELECT tid FROM temp_topic_ids);

  -- Delete modules
  DELETE FROM dt_learning_modules
  WHERE learning_program_tid = program_id;

  -- Eligibility
  DELETE FROM dt_eligibility_responses
  WHERE learning_program_tid = program_id;

  DELETE FROM dt_eligibility_results
  WHERE learning_program_tid = program_id;

  -- Invitees
  DELETE FROM dt_invitees 
  WHERE learning_program_tid = program_id;

  -- Sponsorships
  DELETE FROM dt_user_sponsorships
  WHERE program_sponsorship_tid IN (
    SELECT tid FROM dt_program_sponsorships
    WHERE learning_program_tid = program_id
  );

  DELETE FROM dt_program_sponsorships
  WHERE learning_program_tid = program_id;

  -- Temp table for enrollment IDs
  CREATE TEMPORARY TABLE temp_enrollment_ids (tid BIGINT UNSIGNED);
  INSERT INTO temp_enrollment_ids (tid)
  SELECT tid FROM dt_learning_enrollments
  WHERE learning_program_tid = program_id;

  -- Delete enrollments
  DELETE FROM dt_learning_enrollments
  WHERE tid IN (SELECT tid FROM temp_enrollment_ids);

  -- Assessment responses (joined deletion)
  DELETE ar FROM dt_assessment_responses ar
  JOIN dt_assessment_attempts aa ON ar.attempt_tid = aa.tid
  JOIN dt_learning_assessments la ON aa.assessment_tid = la.tid
  WHERE la.learning_program_tid = program_id;

  -- Assessment attempts
  DELETE FROM dt_assessment_attempts
  WHERE enrollment_tid IN (SELECT tid FROM temp_enrollment_ids);

  -- Assessment questions
  DELETE FROM dt_assessment_questions
  WHERE assessment_tid IN (
    SELECT tid FROM dt_learning_assessments
    WHERE learning_program_tid = program_id
  );

  -- Assessments
  DELETE FROM dt_learning_assessments
  WHERE learning_program_tid = program_id;

  -- Finally delete the program
  DELETE FROM dt_learning_programs
  WHERE tid = program_id;

  -- Drop temp tables
  DROP TEMPORARY TABLE IF EXISTS temp_topic_ids;
  DROP TEMPORARY TABLE IF EXISTS temp_enrollment_ids;

  COMMIT;
END //

DELIMITER ;
call  delete_program(18);