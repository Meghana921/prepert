DROP PROCEDURE IF EXISTS delete_program;
DELIMITER //

CREATE PROCEDURE delete_program(
    IN p_program_id BIGINT UNSIGNED,
    IN p_creator_id BIGINT UNSIGNED
)
BEGIN
   DECLARE enrollment_count BIGINT;
    -- Check if program exists and belongs to the creator
    IF NOT EXISTS (SELECT 1
    FROM dt_learning_programs 
    WHERE tid = p_program_id AND creator_tid = p_creator_id) THEN
     SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Program not found or you are not the creator';
    ELSE
        -- Start transaction for data integrity
        START TRANSACTION;
    
    -- Check if any enrollments exist (completed or active)
    SELECT COUNT(tid) INTO enrollment_count
    FROM dt_learning_enrollments
    WHERE learning_program_tid = p_program_id;
    
       
        
        IF enrollment_count = 0 THEN
            -- HARD DELETE PATH (no enrollments) --
            
            -- Delete assessment questions and assessments
            DELETE FROM dt_assessment_questions
            WHERE assessment_tid IN (
                SELECT tid FROM dt_learning_assessments 
                WHERE learning_program_tid = p_program_id
            );
            
            DELETE FROM dt_learning_assessments
            WHERE learning_program_tid = p_program_id;
            
            -- Delete topics
            DELETE FROM dt_learning_topics
            WHERE module_tid IN (
                SELECT tid FROM dt_learning_modules 
                WHERE learning_program_tid = p_program_id
            );
            
            -- Delete modules
            DELETE FROM dt_learning_modules
            WHERE learning_program_tid = p_program_id;
            
            -- Delete eligibility data
            DELETE FROM dt_eligibility_responses
            WHERE learning_program_tid = p_program_id;
            
            DELETE FROM dt_eligibility_results
            WHERE learning_program_tid = p_program_id;
            
            -- Delete invitees
            DELETE FROM dt_invitees
            WHERE program_tid = p_program_id AND program_type = '1';
            
            -- Delete sponsorship
            DELETE FROM dt_program_sponsorships
            WHERE learning_program_tid = p_program_id;
            
            -- FINAL HARD DELETE
            DELETE FROM dt_learning_programs
            WHERE tid = p_program_id;
            
        ELSE
            -- SOFT DELETE PATH (if enrollments exist)
            UPDATE dt_learning_programs
            SET deleted_at = CURRENT_TIMESTAMP()
            WHERE tid = p_program_id;
        END IF;
        
        COMMIT;
    END IF;
END //

DELIMITER ;