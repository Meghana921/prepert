DROP DATABASE IF EXISTS prepertdevdb;
CREATE DATABASE prepertdevdb
CHARACTER SET utf8mb4 COLLATE  utf8mb4_unicode_ci;
USE prepertdevdb;

-- ============================================================================
-- Core Learning Program Tables (programs, modules, topics)
-- ============================================================================

-- Stores all learning programs/courses with metadata
DROP TABLE IF EXISTS dt_learning_programs;
CREATE TABLE dt_learning_programs (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Program ID
    program_code VARCHAR(20) NOT NULL, -- Short identifier code
    title VARCHAR(100) NOT NULL, -- Program title/name
    description TEXT, -- Full description
    creator_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_users(tid)", -- Creator user ID
    difficulty_level ENUM('0','1','2','3') COMMENT '0-low,1-medium,2-high,3-very_high',
    image_path VARCHAR(255), -- Cover image path
    price DECIMAL(10,2) DEFAULT 0.00, -- Program cost
    access_period_months INT DEFAULT 12, -- Access duration in months
    available_slots INT, -- Max available seats
    campus_hiring BOOLEAN DEFAULT FALSE, -- Campus recruitment program flag
    sponsored BOOLEAN DEFAULT FALSE, -- Sponsored program flag
    minimum_score TINYINT DEFAULT NULL, -- Minimum required score
    experience_from VARCHAR(10), -- Min experience required
    experience_to VARCHAR(10), -- Max experience allowed
    locations VARCHAR(255), -- Job locations (for hiring programs)
    employer_name VARCHAR(100), -- Hiring company name
    regret_message TEXT, -- Rejection message template
    eligibility_template_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_eligibility_templates(tid)",
    invite_template_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_invite_templates(tid)",
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT FALSE, -- Public visibility flag
    is_deleted BOOLEAN DEFAULT false,
    INDEX idx_creator_tid (creator_tid),
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_sponsored (sponsored)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores modules/sections within learning programs
DROP TABLE IF EXISTS dt_learning_modules;
CREATE TABLE dt_learning_modules (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Module ID
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    title VARCHAR(100) NOT NULL, -- Module title
    description TEXT, -- Module description
    sequence_number SMALLINT NOT NULL, -- Display order in program
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores individual learning topics within modules
DROP TABLE IF EXISTS dt_learning_topics;
CREATE TABLE dt_learning_topics (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Topic ID
    module_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_modules(tid)",
    title VARCHAR(100) NOT NULL, -- Topic title
    description TEXT, -- Topic description
    content TEXT, -- Main learning content
    sequence_number SMALLINT NOT NULL, -- Display order in module
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_module_tid (module_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Enrollment & Progress Tracking (user enrollments, progress, questions)
-- ============================================================================

-- Tracks user enrollments in learning programs
DROP TABLE IF EXISTS dt_learning_enrollments;
CREATE TABLE dt_learning_enrollments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Enrollment ID
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    status ENUM('0','1','2','3') DEFAULT '0' COMMENT '0-enrolled,1-in_progress,2-completed,3-expired',
    progress_percentage TINYINT UNSIGNED DEFAULT 0, -- Overall completion %
    enrollment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_on DATE, -- Access expiration date
    completed_at DATETIME, -- Completion timestamp
    certificate_issued BOOLEAN DEFAULT FALSE, -- Certificate generated flag
    certificate_url VARCHAR(255), -- Certificate URL
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    INDEX idx_status (status),
    UNIQUE KEY uk_user_program (user_tid, learning_program_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tracks user progress at topic level
DROP TABLE IF EXISTS dt_learning_progress;
CREATE TABLE dt_learning_progress (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Progress ID
    enrollment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_enrollments(tid)",
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_topics(tid)",
    status ENUM('0','1') DEFAULT '0' COMMENT '0-not_started,1-completed',
    completion_date DATETIME, -- When topic was completed
    INDEX idx_enrollment_tid (enrollment_tid),
    INDEX idx_topic_tid (topic_tid),
    UNIQUE KEY uk_enrollment_topic (enrollment_tid, topic_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores questions asked by learners about topics
DROP TABLE IF EXISTS dt_learning_questions;
CREATE TABLE dt_learning_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Question ID
    enrollment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_enrollments(tid)",
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_topics(tid)",
    question TEXT NOT NULL, -- User's question
    answer TEXT, -- gpt's answer
    asked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_enrollment_tid (enrollment_tid),
    INDEX idx_topic_tid (topic_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Assessment System (tests, questions, attempts, results)
-- ============================================================================

-- Stores topic-level assessments
DROP TABLE IF EXISTS dt_topic_assessments;
CREATE TABLE dt_topic_assessments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Assessment ID
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_topics(tid)",
    total_questions TINYINT DEFAULT 10, -- Number of questions
    gpt_questions_answers JSON NOT NULL, -- GPT-generated Q&A in JSON
    user_responses JSON, -- User answers in JSON
    total_score INT, -- Total marks scored
    taken_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- When taken
    INDEX idx_user (user_tid),
    INDEX idx_topic (topic_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores program-level assessments
DROP TABLE IF EXISTS dt_learning_assessments;
CREATE TABLE dt_learning_assessments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Assessment ID
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    title VARCHAR(100) NOT NULL, -- Assessment title
    description TEXT, -- Description
    question_count SMALLINT UNSIGNED DEFAULT 10, -- Total questions
    passing_score TINYINT UNSIGNED, -- Minimum passing score
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores assessment questions
DROP TABLE IF EXISTS dt_assessment_questions;
CREATE TABLE dt_assessment_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Question ID
    assessment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_assessments(tid)",
    question TEXT NOT NULL, -- Question text
    options JSON, -- Answer options in JSON
    correct_option SMALLINT UNSIGNED, -- Index of correct answer
    score SMALLINT UNSIGNED DEFAULT 1, -- Points for this question
    sequence_number SMALLINT DEFAULT 0, -- Display order
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_assessment_tid (assessment_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tracks user attempts at assessments
DROP TABLE IF EXISTS dt_assessment_attempts;
CREATE TABLE dt_assessment_attempts (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Attempt ID
    assessment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_assessments(tid)",
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    enrollment_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_learning_enrollments(tid)", 
    score SMALLINT UNSIGNED DEFAULT 0, -- Total score
    passed BOOLEAN DEFAULT FALSE, -- Pass/fail status
    completed_at DATETIME, -- Completion time
    INDEX idx_assessment_tid (assessment_tid),
    INDEX idx_user_tid (user_tid),
    INDEX idx_enrollment_tid (enrollment_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores individual question responses
DROP TABLE IF EXISTS dt_assessment_responses;
CREATE TABLE dt_assessment_responses (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Response ID
    attempt_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_assessment_attempts(tid)",
    question_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_assessment_questions(tid)",
    selected_option VARCHAR(50), -- User's selected option
    is_correct BOOLEAN DEFAULT FALSE, -- Correctness flag
    score SMALLINT UNSIGNED DEFAULT 0, -- Points earned
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_attempt_tid (attempt_tid),
    INDEX idx_question_tid (question_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Eligibility & Invite System (templates, responses, results)
-- ============================================================================

-- Stores eligibility templates
DROP TABLE IF EXISTS dt_eligibility_templates;
CREATE TABLE dt_eligibility_templates (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Template ID
    creator_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    name VARCHAR(100) NOT NULL, -- Template name
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_tid (creator_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores eligibility questions
DROP TABLE IF EXISTS dt_eligibility_questions;
CREATE TABLE dt_eligibility_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Question ID
    template_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_eligibility_templates(tid)",
    question TEXT NOT NULL, -- Question text
    deciding_answer ENUM('0','1') DEFAULT '1' COMMENT '0-no,1-yes', -- Correct answer
    sequence_number SMALLINT DEFAULT 0, -- Display order
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_template_tid (template_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores user responses to eligibility questions
DROP TABLE IF EXISTS dt_eligibility_responses;
CREATE TABLE dt_eligibility_responses (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Response ID
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    question_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_eligibility_questions(tid)",
    answer ENUM('0','1') NOT NULL COMMENT '0-no,1-yes', -- User's answer
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    INDEX idx_question_tid (question_tid),
    UNIQUE KEY uk_user_program_question (user_tid, learning_program_tid, question_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores eligibility results
DROP TABLE IF EXISTS dt_eligibility_results;
CREATE TABLE dt_eligibility_results (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Result ID
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    passed BOOLEAN DEFAULT FALSE, -- Eligibility status
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    UNIQUE KEY uk_user_program (user_tid, learning_program_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores invite templates
DROP TABLE IF EXISTS dt_invite_templates;
CREATE TABLE dt_invite_templates (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Template ID
    creator_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    name VARCHAR(100) NOT NULL, -- Template name
    subject VARCHAR(255) NOT NULL, -- Email subject
    body TEXT NOT NULL, -- Email body content
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_tid (creator_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tracks invited users
DROP TABLE IF EXISTS dt_invitees;
CREATE TABLE dt_invitees (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Invitee ID
    program_type ENUM("1","2","3") COMMENT "1-learning,2-interview,3-screening",
    program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    name VARCHAR(100) NOT NULL, -- Invitee name
    email VARCHAR(255) NOT NULL, -- Invitee email
    email_status ENUM("0","1","3") DEFAULT "3" COMMENT "1-sent,0-failed,3-pending",
    status ENUM('0','1','2','3') COMMENT "0-invited,1-enrolled,2-expired,3-declined",
    invite_sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    response_at DATETIME, -- When responded
    enrollment_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_learning_enrollments(tid)", 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_program_tid (program_tid),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Sponsorship System (program sponsors, user sponsorships)
-- ============================================================================

-- Tracks program sponsorships by companies
DROP TABLE IF EXISTS dt_program_sponsorships;
CREATE TABLE dt_program_sponsorships (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Sponsorship ID
    company_user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    seats_allocated INT UNSIGNED DEFAULT 1, -- Total sponsored seats
    seats_used INT UNSIGNED DEFAULT 0, -- Seats utilized
    is_sponsorship_cancelled BOOLEAN DEFAULT FALSE, -- Cancellation status
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company_user_tid (company_user_tid),
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tracks user sponsorships
DROP TABLE IF EXISTS dt_user_sponsorships;
CREATE TABLE dt_user_sponsorships (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- Sponsorship ID
    program_sponsorship_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_program_sponsorships(tid)",
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    enrollment_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_learning_enrollments(tid)",
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_program_sponsorship_tid (program_sponsorship_tid),
    INDEX idx_user_tid (user_tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- User Accounts
-- ============================================================================

-- Stores user account information
DROP TABLE IF EXISTS dt_users;
CREATE TABLE dt_users (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- User ID
    id VARCHAR(30), -- External auth provider ID
    full_Name VARCHAR(200) NOT NULL, -- User's full name
    profilePicture VARCHAR(25), -- Profile picture path
    email VARCHAR(100) NOT NULL UNIQUE, -- Email (unique)
    countryCode varchar(5), -- Country calling code
    phone VARCHAR(15) NOT NULL UNIQUE, -- Phone number (unique)
    userType TINYINT UNSIGNED COMMENT 'User type reference',
    createdAt TIMESTAMP -- Account creation date
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample user record
INSERT INTO dt_users(full_Name,email,phone) VALUES("Meghana","meghana.s921@gmail.com",123456789);