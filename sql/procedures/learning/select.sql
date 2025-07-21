SET SQL_SAFE_UPDATES =0;
SELECT * FROM  dt_invite_templates ;
SELECT * FROM dt_eligibility_templates;
SELECT * FROM dt_eligibility_questions;
SELECT * FROM dt_learning_programs ;
SELECT * FROM dtuserlogin;
SELECT * FROM dt_eligibility_responses;
SELECT * FROM dt_learning_enrollments;
SELECT * FROM dt_program_sponsorships;
SELECT * FROM dt_eligibility_results;
SELECT * FROM dt_topic_assessments;
SELECT * FROM dt_assessment_attempts;
SELECT * FROM dt_assessment_questions;
SELECT * FROM dt_learning_assessments;
SELECT * FROM dt_invitees ;
SELECT * FROM dt_users;
SELECT * FROM dt_assessment_responses;
select * from dt_learning_topics;
SELECT * FROM dt_learning_modules;
SELECT * FROM dt_user_sponsorships;
SELECT * FROM dt_program_sponsorships ;
SELECT * FROM dt_learning_progress;
SELECT * FROM dt_learning_questions;


DELETE FROM dt_program_sponsorships;
DELETE FROM dt_learning_assessments;
DELETE FROM dt_eligibility_templates;
DELETE FROM  dt_invite_templates ;
DELETE FROM dt_learning_programs ;
DELETE FROM  dt_eligibility_questions;
DELETE FROM dt_eligibility_responses;
DELETE FROM  dt_eligibility_questions;
DELETE FROM dt_invitees;
DELETE FROM dt_learning_enrollments;

UPDATE dt_program_sponsorships
SET seats_used =0
WHERE tid=2;
update dt_invitees
SET status= "1"
WHERE tid =2;
