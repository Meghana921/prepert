DROP DATABASE IF EXISTS prepertdevdb;
CREATE DATABASE prepertdevdb
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE prepertdevdb;

-- ============================================================================
-- Core Learning Program Tables
-- ============================================================================
-- Main learning program table
DROP TABLE IF EXISTS dt_learning_programs;
CREATE TABLE dt_learning_programs (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_code VARCHAR(20) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    creator_tid BIGINT UNSIGNED  COMMENT "REFERENCES dt_users(tid)",
    difficulty_level ENUM('0', '1', '2', '3') COMMENT '0-low, 1-medium, 2-high, 3-very_high',
    image_path VARCHAR(255),
    price DECIMAL(10, 2) DEFAULT 0.00,
    access_period_months INT DEFAULT 12,
    available_slots INT,
    campus_hiring BOOLEAN DEFAULT FALSE,
    sponsored BOOLEAN DEFAULT FALSE,
    minimum_score TINYINT DEFAULT NULL,
    experience_from VARCHAR(10),
    experience_to VARCHAR(10),
    locations VARCHAR(255),
    employer_name VARCHAR(100),
    regret_message TEXT,
    eligibility_template_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_eligibility_templates(tid)",
    invite_template_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_invite_templates(tid)",
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT FALSE,
    INDEX idx_creator_tid (creator_tid),
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_sponsored (sponsored)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Modules (sections of a learning program)
DROP TABLE IF EXISTS dt_learning_modules;
CREATE TABLE dt_learning_modules (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    title VARCHAR(100) NOT NULL,
    description TEXT,
    sequence_number SMALLINT NOT NULL COMMENT 'Order of the module',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Topics (individual topics within modules)
DROP TABLE IF EXISTS dt_learning_topics;
CREATE TABLE dt_learning_topics (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_modules(tid)",
    title VARCHAR(100) NOT NULL,
    description TEXT,		
    content TEXT COMMENT 'Actual content',
    sequence_number SMALLINT NOT NULL COMMENT 'Order of the topic',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_module_tid (module_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- Enrollment & Progress Tables
-- ============================================================================

-- User subscriptions/enrollments
DROP TABLE IF EXISTS dt_learning_enrollments;
CREATE TABLE dt_learning_enrollments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    status ENUM('0','1','2','3') NOT NULL DEFAULT '0' COMMENT '0:enrolled,1:in_progress,2:completed,3:expired',
    progress_percentage TINYINT UNSIGNED DEFAULT 0 COMMENT 'Overall completion percentage',
    enrollment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_on DATE COMMENT 'When access expires',
    completed_at DATETIME COMMENT 'When fully completed',
    certificate_issued BOOLEAN DEFAULT FALSE,
    certificate_url VARCHAR(255),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    INDEX idx_status (status),
    UNIQUE KEY uk_user_program (user_tid, learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Detailed topic-level progress tracking
DROP TABLE IF EXISTS dt_learning_progress;
CREATE TABLE dt_learning_progress (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enrollment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_enrollments(tid)",
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_topics(tid)",
    status ENUM('0', '1', '2') NOT NULL DEFAULT '0' COMMENT "0:not_started,1:in_progress,2:completed",
    completion_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_enrollment_tid (enrollment_tid),
    INDEX idx_topic_tid (topic_tid),
    UNIQUE KEY uk_enrollment_topic (enrollment_tid, topic_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Questions asked by learners during the program
DROP TABLE IF EXISTS dt_learning_questions;
CREATE TABLE dt_learning_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enrollment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_enrollments(tid)",
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_topics(tid)",
    question TEXT NOT NULL,
    answer TEXT,
    asked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    answered_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_enrollment_tid (enrollment_tid),
    INDEX idx_topic_tid (topic_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- Assessment Tables
-- ============================================================================

DROP TABLE IF EXISTS dt_topic_assessments;
CREATE TABLE dt_topic_assessments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_topics(tid)",
    total_questions TINYINT DEFAULT 10,
    gpt_questions_answers JSON NOT NULL COMMENT 'GPT-generated questions and correct in JSON format',
    user_responses JSON COMMENT 'User responses in JSON format',
    total_score INT COMMENT '1 marks for each question',
    taken_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'When assessment was taken',
    INDEX idx_user (user_tid),
    INDEX idx_topic (topic_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Assessments for learning programs
DROP TABLE IF EXISTS dt_learning_assessments;
CREATE TABLE dt_learning_assessments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    title VARCHAR(100) NOT NULL,
    description TEXT,
    question_count SMALLINT UNSIGNED DEFAULT 10,
    passing_score TINYINT UNSIGNED,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Assessment questions
DROP TABLE IF EXISTS dt_assessment_questions;
CREATE TABLE dt_assessment_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assessment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_assessments(tid)",
    question TEXT NOT NULL,
    options JSON COMMENT 'Question options in JSON format',
    correct_option SMALLINT UNSIGNED COMMENT 'Index of correct option',
    score SMALLINT UNSIGNED DEFAULT 1,
    sequence_number SMALLINT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_assessment_tid (assessment_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- User assessment attempts
DROP TABLE IF EXISTS dt_assessment_attempts;
CREATE TABLE dt_assessment_attempts (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assessment_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_assessments(tid)",
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    enrollment_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_learning_enrollments(tid)", 
    score SMALLINT UNSIGNED DEFAULT 0,
    passed BOOLEAN DEFAULT FALSE,
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_assessment_tid (assessment_tid),
    INDEX idx_user_tid (user_tid),
    INDEX idx_enrollment_tid (enrollment_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- User assessment answers
DROP TABLE IF EXISTS dt_assessment_responses;
CREATE TABLE dt_assessment_responses (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    attempt_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_assessment_attempts(tid)",
    question_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_assessment_questions(tid)",
    selected_option VARCHAR(50),
    is_correct BOOLEAN DEFAULT FALSE,
    score SMALLINT UNSIGNED DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_attempt_tid (attempt_tid),
    INDEX idx_question_tid (question_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- Eligibility & Invite Templates
-- ============================================================================

CREATE TABLE dt_eligibility_templates (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    creator_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    name VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_tid (creator_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS dt_eligibility_questions;
CREATE TABLE dt_eligibility_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    template_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES  dt_eligibility_templates(tid)",
    question TEXT NOT NULL,
    deciding_answer ENUM('0', '1') NOT NULL DEFAULT '1' COMMENT "0:no,1:yes",
    sequence_number SMALLINT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_template_tid (template_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS dt_eligibility_responses;
CREATE TABLE dt_eligibility_responses (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    question_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_eligibility_questions(tid)",
    answer ENUM('0', '1') NOT NULL COMMENT "0:no,1:yes", 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    INDEX idx_question_tid (question_tid),
    UNIQUE KEY uk_user_program_question (user_tid, learning_program_tid, question_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS dt_eligibility_results;
CREATE TABLE dt_eligibility_results (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    passed BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    UNIQUE KEY uk_user_program (user_tid, learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS  dt_invite_templates;
CREATE TABLE dt_invite_templates (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    creator_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_tid (creator_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS dt_invitees;
CREATE TABLE dt_invitees (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_type ENUM("1","2","3") COMMENT "1:learning,2:interview,3:screening",
    program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    email_status ENUM("0","1","3") DEFAULT "3" COMMENT "1:sent,0:failed,3:pending",
    status ENUM('0', '1', '2','3') COMMENT "0:invited,1:enrolled,2:expired,3:declined",
    invite_sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    response_at DATETIME,
    enrollment_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_learning_enrollments(tid)", 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_program_tid (program_tid),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- Sponsorship Tables
-- ============================================================================
DROP TABLE IF EXISTS dt_program_sponsorships ;
CREATE TABLE dt_program_sponsorships (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_learning_programs(tid)",
    seats_allocated INT UNSIGNED NOT NULL DEFAULT 1,
    seats_used INT UNSIGNED DEFAULT 0,
    is_sponsorship_cancelled BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company_user_tid (company_user_tid),
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

DROP TABLE IF EXISTS dt_user_sponsorships;
CREATE TABLE dt_user_sponsorships (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_sponsorship_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_program_sponsorships(tid)",
    user_tid BIGINT UNSIGNED NOT NULL COMMENT "REFERENCES dt_users(tid)",
    enrollment_tid BIGINT UNSIGNED COMMENT "REFERENCES dt_learning_enrollments(tid)", -- 'Created enrollment if accepted'
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_program_sponsorship_tid (program_sponsorship_tid),
    INDEX idx_user_tid (user_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- End of Learning Schema
-- ============================================================================
DROP TABLE IF EXISTS  dt_users;
CREATE TABLE dt_users (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- User ID
    id VARCHAR(30), -- unique identifier for the user (from LinkedIn, Google, etc.)
    full_Name VARCHAR(200) NOT NULL,
    profilePicture VARCHAR(25),
    email VARCHAR(100) NOT NULL UNIQUE,
    countryCode varchar(5),
    phone VARCHAR(15) NOT NULL UNIQUE,
    userType TINYINT UNSIGNED COMMENT 'REFERENCES mtusertype(tid)',
    createdAt TIMESTAMP
);

INSERT INTO dt_users(full_Name,email,phone)VALUES("Meghana","meghana.s921@gmail.com",123456789);