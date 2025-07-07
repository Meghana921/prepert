DROP DATABASE IF EXISTS prepertdevdb;
CREATE DATABASE prepertdevdb
CHARACTER SET utf8mb4 COLLATE  utf8mb4_unicode_ci;
USE prepertdevdb;
-- ============================================================================
-- Core Learning Program Tables
-- ============================================================================
-- Main learning program table
DROP TABLE IF EXISTS dt_learning_programs;
CREATE TABLE dt_learning_programs (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    creator_tid BIGINT UNSIGNED NOT NULL,
    difficulty_level ENUM('low', 'medium', 'high', 'very_high') DEFAULT 'medium',
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
    eligibility_template_tid BIGINT UNSIGNED,
    invite_template_tid BIGINT UNSIGNED,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_tid (creator_tid),
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_sponsored (sponsored)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Modules (sections of a learning program)
DROP TABLE IF EXISTS dt_learning_modules;
CREATE TABLE dt_learning_modules (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    learning_program_tid BIGINT UNSIGNED NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    sequence_number SMALLINT NOT NULL COMMENT 'Order of the module',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;


-- Topics (individual lessons within modules)
DROP TABLE IF EXISTS dt_learning_topics;
CREATE TABLE dt_learning_topics (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_tid BIGINT UNSIGNED NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,		
    content TEXT COMMENT 'Actual content or reference to content',
    sequence_number SMALLINT NOT NULL COMMENT 'Order of the topic',
    progress_weight INT DEFAULT 1 COMMENT 'Weight in progress calculations',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_module_tid (module_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ============================================================================
-- Enrollment & Progress Tables
-- ============================================================================
-- User subscriptions/enrollments


CREATE TABLE dt_learning_enrollments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL,
    learning_program_tid BIGINT UNSIGNED NOT NULL,
    status ENUM(
        'enrolled',
        'in_progress',
        'completed',
        'expired'
    ) NOT NULL DEFAULT 'enrolled',
    progress_percentage TINYINT UNSIGNED DEFAULT 0 COMMENT 'Overall completion percentage',
    enrollment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_on DATE COMMENT 'When access expires',
    completed_at DATETIME COMMENT 'When fully completed',
    certificate_issued BOOLEAN DEFAULT FALSE,
    certificate_url VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
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
    enrollment_tid BIGINT UNSIGNED NOT NULL,
    topic_tid BIGINT UNSIGNED NOT NULL,
    status ENUM('not_started', 'in_progress', 'completed') NOT NULL DEFAULT 'not_started',
    completion_date DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_enrollment_tid (enrollment_tid),
    INDEX idx_topic_tid (topic_tid),
    UNIQUE KEY uk_enrollment_topic (enrollment_tid, topic_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Questions asked by learners during the program
DROP TABLE IF EXISTS dt_learning_questions;
CREATE TABLE dt_learning_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    enrollment_tid BIGINT UNSIGNED NOT NULL,
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT 'Associated with specific topic',
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
    user_tid BIGINT UNSIGNED NOT NULL COMMENT 'User who took the assessment',
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT 'Topic being assessed',
    total_questions TINYINT DEFAULT 10,
    gpt_questions_answers JSON NOT NULL COMMENT 'GPT-generated questions and correct  in JSON format',
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
    learning_program_tid BIGINT UNSIGNED NOT NULL,
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
    assessment_tid BIGINT UNSIGNED NOT NULL,
    question TEXT NOT NULL,
    options JSON COMMENT 'Question options in JSON format',
    correct_option SMALLINT UNSIGNED COMMENT 'INDEX of correct option',
    score SMALLINT UNSIGNED DEFAULT 1,
	sequence_number SMALLINT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_assessment_tid (assessment_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- User assessment attempts
DROP TABLE IF EXISTS dt_assessment_attempts ;
CREATE TABLE dt_assessment_attempts (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assessment_tid BIGINT UNSIGNED NOT NULL,
    user_tid BIGINT UNSIGNED NOT NULL,
    enrollment_tid BIGINT UNSIGNED COMMENT 'If taken as part of enrollment',
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
    attempt_tid BIGINT UNSIGNED NOT NULL,
    question_tid BIGINT UNSIGNED NOT NULL,
    selected_option VARCHAR(50),
    is_correct BOOLEAN DEFAULT FALSE,
    score SMALLINT UNSIGNED DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_attempt_tid (attempt_tid),
    INDEX idx_question_tid (question_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Topic-based assessment table
DROP TABLE IF EXISTS dt_topic_assessments;
CREATE TABLE dt_topic_assessments (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL COMMENT 'User who took the assessment',
    topic_tid BIGINT UNSIGNED NOT NULL COMMENT 'Topic being assessed',
    total_questions TINYINT DEFAULT 10,
    gpt_questions_answers JSON NOT NULL COMMENT 'GPT-generated questions and correct  in JSON format',
    user_responses JSON COMMENT 'User responses in JSON format',
    total_score INT COMMENT '1 marks for each question',
    taken_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'When assessment was taken',
    INDEX idx_user (user_tid),
    INDEX idx_topic (topic_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- Eligibility & Invite Templates
-- ============================================================================
-- Eligibility templates that can be reused across programs
CREATE TABLE dt_eligibility_templates (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    creator_tid BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_tid (creator_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Individual eligibility questions within templates
CREATE TABLE dt_eligibility_questions (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    template_tid BIGINT UNSIGNED NOT NULL,
    question TEXT NOT NULL,
    deciding_answer ENUM('yes', 'no') NOT NULL DEFAULT 'yes',
    sequence_number SMALLINT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_template_tid (template_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- User responses to eligibility questions
CREATE TABLE dt_eligibility_responses (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL,
    learning_program_tid BIGINT UNSIGNED NOT NULL,
    question_tid BIGINT UNSIGNED NOT NULL,
    answer ENUM('yes', 'no') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    INDEX idx_question_tid (question_tid),
    UNIQUE KEY uk_user_program_question (user_tid, learning_program_tid, question_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Results of eligibility tests
CREATE TABLE dt_eligibility_results (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_tid BIGINT UNSIGNED NOT NULL,
    learning_program_tid BIGINT UNSIGNED NOT NULL,
    passed BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_tid (user_tid),
    INDEX idx_learning_program_tid (learning_program_tid),
    UNIQUE KEY uk_user_program (user_tid, learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Invite templates for sending invitations to programs
CREATE TABLE dt_invite_templates (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    creator_tid BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_tid (creator_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- People invited to learning programs
CREATE TABLE dt_invitees (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    learning_program_tid BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status ENUM('invited', 'accepted', 'declined', 'expired') NOT NULL DEFAULT 'invited',
    invite_sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    response_at DATETIME,
    enrollment_tid BIGINT UNSIGNED COMMENT 'Created enrollment if accepted',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_learning_program_tid (learning_program_tid),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ============================================================================
-- Sponsorship Tables
-- ============================================================================
-- Company sponsorship of learning programs
CREATE TABLE dt_program_sponsorships (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_user_tid BIGINT UNSIGNED NOT NULL COMMENT 'Company user providing sponsorship',
    learning_program_tid BIGINT UNSIGNED NOT NULL COMMENT 'Sponsored program',
    seats_allocated INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Number of sponsorships',
    seats_used INT UNSIGNED DEFAULT 0 COMMENT 'Seats already assigned',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company_user_tid (company_user_tid),
    INDEX idx_learning_program_tid (learning_program_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- User sponsorship offers and acceptance
DROP TABLE IF EXISTS dt_user_sponsorships;
CREATE TABLE dt_user_sponsorships (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_sponsorship_tid BIGINT UNSIGNED NOT NULL,
    user_tid BIGINT UNSIGNED NOT NULL,
    enrollment_tid BIGINT UNSIGNED COMMENT 'Created enrollment if accepted',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_program_sponsorship_tid (program_sponsorship_tid),
    INDEX idx_user_tid (user_tid)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- ============================================================================
-- End of Learning Schema
-- ============================================================================
CREATE TABLE dt_users (
    tid BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, -- User ID
    id VARCHAR(30), -- unique identifier for the user (from linkedIn, Google, etc.)
    full_Name VARCHAR(200) NOT NULL, -- Full name of the user
    profilePicture VARCHAR(25), -- Profile picture filename or URL
    email VARCHAR(100) NOT NULL UNIQUE, -- User's email address
    countryCode varchar(5), -- Country code for the user's phone number
    phone VARCHAR(15) NOT NULL UNIQUE, -- User's phone number
    userType TINYINT UNSIGNED COMMENT 'REFERENCES mtusertype(tid)', -- User type (e.g., individual, organization)
    createdAt TIMESTAMP -- Timestamp when the user was created
);

