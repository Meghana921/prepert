# Learning Module API Documentation

> **Note:** This backend uses ES Modules (ESM) system. All code uses `import`/`export` syntax and `.js` extensions in import paths.

**Base URL:** `http://localhost:3000/api/learning/`

---

## **🎯 Complete API Testing Sequence**

### **Phase 1: Template Creation (Required First)**
```
1. Create Eligibility Template → get eligibility_template_id
2. Create Invite Template → get invite_template_id
```

### **Phase 2: Program Creation & Setup**
```
3. Create Program → use template IDs from Phase 1
4. Add Course Content → use program_id from Step 3
5. Create Program Assessment → use program_id from Step 3
```

### **Phase 3: User Operations**
```
6. Submit Eligibility Response → use template_id from Step 1
7. Enroll in Program → use program_id from Step 3
8. Track Progress → use enrollment_id from Step 7
9. Submit Assessment → use assessment_id from Step 5
10. Download Certificate → use enrollment_id from Step 7
```

### **Phase 4: Management & Viewing**
```
11. List Programs
12. View Program Details
13. List Templates
14. View Assessment Details
```

---

## **📋 Phase 1: Template Creation**

### **1. Create Eligibility Template**
**POST** `http://localhost:3000/api/learning/eligibility/add-eligibility-template`

**Request Body:**
```json
{
  "creator_id": 1,
  "template_name": "JavaScript Bootcamp Eligibility",
  "eligibility_questions": [
    {
      "question": "Do you have basic programming knowledge?",
      "deciding_answer": "yes",
      "sequence_number": 1
    },
    {
      "question": "Are you available for 6 months?",
      "deciding_answer": "yes",
      "sequence_number": 2
    },
    {
      "question": "Do you have a computer with internet?",
      "deciding_answer": "yes",
      "sequence_number": 3
    }
  ]
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "template_id": 55,
    "template_name": "JavaScript Bootcamp Eligibility"
  },
  "message": "Eligibility template created successfully"
}
```

### **2. Create Invite Template**
**POST** `http://localhost:3000/api/learning/invite/create-invite-template`

**Request Body:**
```json
{
  "creator_id": 1,
  "name": "JavaScript Bootcamp Invitation",
  "subject": "You're invited to join our JavaScript Bootcamp!",
  "body": "Dear {{name}},\n\nYou have been invited to join our exclusive JavaScript Bootcamp program.\n\nProgram Details:\n- Duration: 6 months\n- Price: $100\n- Location: Remote\n\nClick here to enroll: {{enrollment_link}}\n\nBest regards,\nPrepert Team"
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "template_id": 66,
    "template_name": "JavaScript Bootcamp Invitation"
  }
}
```

---

## **📋 Phase 2: Program Creation & Setup**

### **3. Create Learning Program**
**POST** `http://localhost:3000/api/learning/programs/create-program`

**Request Body:**
```json
{
  "title": "JavaScript Bootcamp 2024",
  "description": "Learn JavaScript from scratch to advanced concepts",
  "creator_id": 1,
  "difficulty_level": "medium",
  "image_path": "/images/javascript-bootcamp.jpg",
  "price": 100.00,
  "access_period_months": 6,
  "available_slots": 30,
  "campus_hiring": false,
  "sponsored": false,
  "minimum_score": 70,
  "experience_from": "0",
  "experience_to": "2",
  "locations": "Remote",
  "employer_name": "Prepert",
  "regret_message": "Sorry, you are not eligible for this program.",
  "eligibility_template_id": 55,
  "invite_template_id": 66,
  "invitee": [
    {
      "name": "Alice Johnson",
      "email": "alice.johnson@example.com"
    },
    {
      "name": "Bob Smith",
      "email": "bob.smith@example.com"
    },
    {
      "name": "Carol Davis",
      "email": "carol.davis@example.com"
    }
  ]
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "program_id": 123,
    "program_name": "JavaScript Bootcamp 2024"
  },
  "message": "Program created successfully!"
}
```

### **4. Add Course Content**
**POST** `http://localhost:3000/api/learning/course-content/`

**Request Body:**
```json
{
  "learning_program_tid": 123,
  "module_title": "JavaScript Fundamentals",
  "module_description": "Learn the basics of JavaScript programming",
  "module_sequence": 1,
  "topics": [
    {
      "topic_title": "Introduction to JavaScript",
      "topic_description": "What is JavaScript and why use it?",
      "topic_content": "JavaScript is a programming language that enables interactive web pages...",
      "topic_sequence": 1,
      "progress_weight": 20
    },
    {
      "topic_title": "Variables and Data Types",
      "topic_description": "Learn about variables, strings, numbers, and booleans",
      "topic_content": "Variables are containers for storing data values...",
      "topic_sequence": 2,
      "progress_weight": 30
    },
    {
      "topic_title": "Functions",
      "topic_description": "Creating and using functions in JavaScript",
      "topic_content": "Functions are reusable blocks of code...",
      "topic_sequence": 3,
      "progress_weight": 50
    }
  ]
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "module_id": 456,
    "topics_added": 3
  },
  "message": "Course content added successfully"
}
```

### **5. Create Program Assessment**
**POST** `http://localhost:3000/api/learning/assessment/program-assessment`

**Request Body:**
```json
{
  "program_id": 123,
  "title": "JavaScript Fundamentals Assessment",
  "description": "Test your knowledge of JavaScript basics",
  "question_count": 5,
  "passing_score": 70,
  "questions": [
    {
      "question": "What is JavaScript?",
      "options": {
        "A": "A markup language",
        "B": "A programming language",
        "C": "A styling language",
        "D": "A database language"
      },
      "correct_option": "B",
      "score": 20
    },
    {
      "question": "How do you declare a variable in JavaScript?",
      "options": {
        "A": "var x = 5;",
        "B": "variable x = 5;",
        "C": "v x = 5;",
        "D": "declare x = 5;"
      },
      "correct_option": "A",
      "score": 20
    },
    {
      "question": "What is the correct way to write a function?",
      "options": {
        "A": "function myFunction() {}",
        "B": "func myFunction() {}",
        "C": "def myFunction() {}",
        "D": "method myFunction() {}"
      },
      "correct_option": "A",
      "score": 20
    },
    {
      "question": "Which operator is used for assignment?",
      "options": {
        "A": "==",
        "B": "=",
        "C": "===",
        "D": "!="
      },
      "correct_option": "B",
      "score": 20
    },
    {
      "question": "How do you add a comment in JavaScript?",
      "options": {
        "A": "<!-- comment -->",
        "B": "// comment",
        "C": "/* comment */",
        "D": "Both B and C"
      },
      "correct_option": "D",
      "score": 20
    }
  ]
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "assessment_id": 789,
    "total_questions": 5
  }
}
```

---

## **📋 Phase 3: User Operations**

### **6. Submit Eligibility Response**
**POST** `http://localhost:3000/api/learning/eligibility/submit-eligibility-response`

**Request Body:**
```json
{
  "user_id": 10,
  "template_id": 55,
  "response": "Eligible"
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "user_id": 10,
    "template_id": 55,
    "eligibility_status": "Eligible"
  },
  "message": "Eligibility response submitted successfully"
}
```

### **7. Enroll in Program**
**POST** `http://localhost:3000/api/learning/programs/program-enrollment`

**Request Body:**
```json
{
  "user_id": 10,
  "program_id": 123
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "enrollment_id": 101,
    "user_id": 10,
    "program_id": 123,
    "enrollment_date": "2024-01-15T10:30:00Z",
    "expires_on": "2024-07-15T10:30:00Z"
  },
  "message": "Enrolled successfully"
}
```

### **8. Track Progress**
**POST** `http://localhost:3000/api/learning/track-progress/`

**Request Body:**
```json
{
  "enrollment_tid": 101,
  "topic_tid": 1,
  "status": "completed"
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "enrollment_id": 101,
    "progress_percentage": 33,
    "completed_topics": 1,
    "total_topics": 3
  },
  "message": "Progress updated successfully"
}
```

### **9. Submit Assessment**
**POST** `http://localhost:3000/api/learning/assessment/submit-assessment`

**Request Body:**
```json
{
  "user_id": 10,
  "program_id": 123,
  "responses": [
    {
      "question_id": 1,
      "answer": "B"
    },
    {
      "question_id": 2,
      "answer": "A"
    },
    {
      "question_id": 3,
      "answer": "A"
    },
    {
      "question_id": 4,
      "answer": "B"
    },
    {
      "question_id": 5,
      "answer": "D"
    }
  ]
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "attempt_id": 202,
    "total_score": 100,
    "passing_score": 70,
    "passed": true,
    "percentage": 100
  },
  "message": "Assessment submitted successfully"
}
```

### **10. Download Certificate (When 100% Complete)**
**POST** `http://localhost:3000/api/learning/get-certificate/get-certificate`

**Request Body:**
```json
{
  "enrollment_tid": 101
}
```

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "certificate_url": "/certificates/cert_101.pdf",
    "download_link": "http://localhost:3000/api/learning/certificates/download/cert_101.pdf",
    "completion_date": "2024-01-20T15:45:00Z"
  },
  "message": "Certificate generated successfully"
}
```

---

## **📋 Phase 4: Management & Viewing**

### **11. List All Programs**
**GET** `http://localhost:3000/api/learning/programs/list-programs`

**Expected Response:**
```json
{
  "status": true,
  "data": [
    {
      "program_id": 123,
      "title": "JavaScript Bootcamp 2024",
      "description": "Learn JavaScript from scratch to advanced concepts",
      "creator_id": 1,
      "difficulty_level": "medium",
      "price": 100.00,
      "available_slots": 27,
      "created_at": "2024-01-10T09:00:00Z"
    }
  ]
}
```

### **12. View Specific Program**
**GET** `http://localhost:3000/api/learning/programs/view-program?program_id=123`

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "program_id": 123,
    "title": "JavaScript Bootcamp 2024",
    "description": "Learn JavaScript from scratch to advanced concepts",
    "creator_id": 1,
    "difficulty_level": "medium",
    "price": 100.00,
    "access_period_months": 6,
    "available_slots": 27,
    "campus_hiring": false,
    "sponsored": false,
    "minimum_score": 70,
    "experience_from": "0",
    "experience_to": "2",
    "locations": "Remote",
    "employer_name": "Prepert",
    "eligibility_template_id": 55,
    "invite_template_id": 66,
    "created_at": "2024-01-10T09:00:00Z"
  }
}
```

### **13. List Eligibility Templates**
**GET** `http://localhost:3000/api/learning/eligibility/list-eligibility-template?creator_id=1`

**Expected Response:**
```json
{
  "status": true,
  "data": [
    {
      "template_id": 55,
      "template_name": "JavaScript Bootcamp Eligibility"
    }
  ]
}
```

### **14. List Invite Templates**
**GET** `http://localhost:3000/api/learning/invite/list-invite-template?creator_id=1`

**Expected Response:**
```json
{
  "status": true,
  "data": [
    {
      "template_id": 66,
      "template_name": "JavaScript Bootcamp Invitation"
    }
  ]
}
```

### **15. View Program Assessment**
**GET** `http://localhost:3000/api/learning/assessment/view-program-assessment?program_id=123`

**Expected Response:**
```json
{
  "status": true,
  "data": {
    "assessment_id": 789,
    "title": "JavaScript Fundamentals Assessment",
    "description": "Test your knowledge of JavaScript basics",
    "question_count": 5,
    "passing_score": 70,
    "questions": [
      {
        "question_id": 1,
        "question": "What is JavaScript?",
        "options": {
          "A": "A markup language",
          "B": "A programming language",
          "C": "A styling language",
          "D": "A database language"
        },
        "correct_option": "B",
        "score": 20
      }
    ],
    "created_at": "2024-01-10T10:00:00Z"
  }
}
```

---

## **🔧 Postman Testing Setup**

### **Environment Variables (Set in Postman)**
```
base_url: http://localhost:3000/api/learning
creator_id: 1
user_id: 10
```

### **Testing Order:**
1. **Phase 1:** Create templates (Steps 1-2)
2. **Phase 2:** Create program and content (Steps 3-5)
3. **Phase 3:** Test user operations (Steps 6-10)
4. **Phase 4:** Test management operations (Steps 11-15)

### **Headers for All Requests:**
```
Content-Type: application/json
Accept: application/json
```

### **Testing Tips:**
- **Save IDs:** Store returned IDs (template_id, program_id, enrollment_id) as variables
- **Check Status:** Always verify `status: true` in responses
- **Error Handling:** Test with invalid data to see error responses
- **Dependencies:** Follow the exact sequence - don't skip steps

---

## **🚨 Error Response Examples**

### **Missing Dependencies:**
```json
{
  "status": false,
  "message": "Eligibility template not found"
}
```

### **Invalid Data:**
```json
{
  "status": false,
  "message": "Invalid program_id provided"
}
```

### **Duplicate Entry:**
```json
{
  "status": false,
  "message": "JavaScript Bootcamp 2024 program already exists"
}
```

---

**🎉 Your API is now ready for comprehensive Postman testing with proper sequence and dummy data!** 