# LMS Learning Backend API Documentation

This document describes all API endpoints available in the backend. Use these details to test with Postman or similar tools.

---

## Health Check

**GET** `/health`

**Description:** Check if the server is running.

**Response:**
```json
{ "status": "ok" }
```

---

## Add Course Content

**POST** `/api/course-content`

**Description:** Add a new module and its topics to a learning program.

**Request Body (JSON):**
```json
{
  "learning_program_tid": 3001,
  "module_title": "Triggers in SQL",
  "module_description": "Learn about MySQL triggers.",
  "module_sequence": 1,
  "topics": [
    {
      "title": "Before Insert Trigger",
      "description": "Before insert logic",
      "content": "CREATE TRIGGER ...",
      "sequence_number": 1,
      "progress_weight": 1
    },
    {
      "title": "After Delete Trigger",
      "description": "After delete logic",
      "content": "AFTER DELETE ...",
      "sequence_number": 2,
      "progress_weight": 1
    }
  ]
}
```
**Success Response:**
```json
{
  "module_id": 4002,
  "message": "Course content added successfully",
  "topics_added": 2
}
```
**Error Response:**
```json
{ "error": "learning_program_tid, module_title, module_description, module_sequence, and topics are required" }
```

---

## Edit Course Content

**PUT** `/api/course-content`

**Description:** Edit a module or a topic. Only these four fields are required in the body:
- `content_type` ("module" or "topic")
- `content_id` (number)
- `content_json` (object with fields to update)
- `learning_program_tid` (number)

**Request Body (JSON) for editing a module:**
```json
{
  "content_type": "module",
  "content_id": 4002,
  "content_json": {
    "title": "Triggers in SQL (Updated)",
    "description": "Updated module description",
    "sequence_number": 2
  },
  "learning_program_tid": 3001
}
```
**Request Body (JSON) for editing a topic:**
```json
{
  "content_type": "topic",
  "content_id": 5003,
  "content_json": {
    "title": "Before Insert Trigger (Updated)",
    "description": "Updated before insert logic",
    "content": "NEW TRIGGER ...",
    "sequence_number": 1,
    "progress_weight": 2
  },
  "learning_program_tid": 3001
}
```
**Success Response (module):**
```json
{ "message": "Module updated successfully" }
```
**Success Response (topic):**
```json
{ "message": "Topic updated successfully" }
```
**Error Response:**
```json
{ "error": "content_type, content_id, content_json, and learning_program_tid are required" }
```

---

## Delete Course Content

**DELETE** `/api/course-content`

**Description:** Delete a module or topic from a learning program.

**Request Body (JSON):**
```json
{
  "content_type": "topic",
  "content_id": 5003,
  "learning_program_tid": 3001
}
```
**Success Response (topic):**
```json
{
  "message": "Topic deleted successfully",
  "affected_rows": 1
}
```
**Success Response (module):**
```json
{
  "message": "Module and all its topics deleted successfully",
  "affected_rows": 1
}
```
**Error Response:**
```json
{ "error": "content_type, content_id, and learning_program_tid are required" }
```

---

## Add Learning Question

**POST** `/api/learning-question`

**Description:** Add a question for a topic by an enrolled user.

**Request Body (JSON):**
```json
{
  "enrollment_tid": 6001,
  "topic_tid": 5001,
  "question": {
    "question_text": "How do AFTER triggers differ from BEFORE triggers?",
    "type": "text"
  }
}
```
**Success Response:**
```json
{
  "p_question_id": 7001,
  "p_status_code": 200,
  "p_message": "Question added successfully"
}
```
**Error Response:**
```json
{ "error": "enrollment_tid, topic_tid, and question are required" }
```

---

## Send Invite

**POST** `/api/invites`

**Description:** Send an invite to a user for a program. Generates a unique code, stores it, and sends an email invite.

**Request Body (JSON):**
```json
{
  "email": "ravi@example.com",
  "programId": 3001
}
```
**Success Response:**
```json
{
  "success": true,
  "code": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```
**Error Response:**
```json
{ "error": "email and programId are required" }
```

---

## Redeem Invite

**POST** `/api/invites/redeem`

**Description:** Redeem an invite code to enroll a user in a program. Validates the code and enrolls the user if valid.

**Request Body (JSON):**
```json
{
  "email": "devashish.ind@gmail.com",
  "code": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": 3001
}
```
**Success Response:**
```json
{
  "success": true,
  "programId": 3001
}
```
**Error Response:**
```json
{ "error": "email, code, and userId are required" }
```

---

## Track Learning Progress

**POST** `/api/track-progress`

**Description:** Update a user's progress on a topic.

**Request Body (JSON):**
```json
{
  "enrollment_tid": 6001,
  "topic_tid": 5001,
  "status": "completed"
}
```
**Success Response:**
```json
{
  "p_status_code": 200,
  "p_message": "Progress updated successfully. Overall progress: 100%"
}
```
**Error Response:**
```json
{ "error": "enrollment_tid, topic_tid, and status are required" }
```

---

## List Subscribed Courses for a User

**GET** `/api/user/2001/subscribed-courses`

**Description:** List all courses a user is subscribed to.

**Success Response:**
```json
[
  {
    "enrollment_id": 6001,
    "user_tid": 2001,
    "learning_program_tid": 3001,
    "course_title": "Advanced SQL Bootcamp",
    "course_description": "A deep dive into SQL procedures.",
    "difficulty_level": "high",
    "image_path": null,
    "price": 299.99,
    "access_period_months": null,
    "campus_hiring": null,
    "sponsored": true,
    "employer_name": "Acme Corp",
    "enrollment_status": "in_progress",
    "progress_percentage": 50,
    "enrollment_date": "2024-05-01T10:00:00.000Z",
    "expires_on": "2024-08-01T10:00:00.000Z",
    "completed_at": null,
    "certificate_issued": false,
    "certificate_url": null,
    "creator_name": "Acme Corp Admin",
    "creator_email": "admin@acme.com",
    "days_remaining": 60,
    "is_expired": false
  }
]
```

---

## View Company Subscribers

**GET** `/api/company-subscribers?company_user_tid=1001&learning_program_tid=3001&status=active`

**Description:** List all users subscribed to company-created or sponsored courses.

**Success Response:**
```json
[
  {
    "enrollment_id": 6001,
    "user_tid": 2001,
    "subscriber_name": "John Doe",
    "subscriber_email": "john@example.com",
    "subscriber_phone": "8888811111",
    "program_id": 3001,
    "program_title": "Advanced SQL Bootcamp",
    "creator_tid": 1001,
    "enrollment_status": "in_progress",
    "progress_percentage": 50,
    "enrollment_date": "2024-05-01T10:00:00.000Z",
    "expires_on": "2024-08-01T10:00:00.000Z",
    "completed_at": null,
    "certificate_issued": false,
    "sponsorship_status": null,
    "seats_allocated": null,
    "seats_used": null,
    "relationship_type": "Created"
  }
]
```

---

## List All Learning Courses

**GET** `/api/courses?creator_tid=1001&difficulty_level=high&sponsored=true&limit=10&offset=0`

**Description:** List all learning courses with optional filters and pagination.

**Success Response:**
```json
[
  {
    "program_id": 3001,
    "title": "Advanced SQL Bootcamp",
    "description": "A deep dive into SQL procedures.",
    "creator_tid": 1001,
    "creator_name": "Acme Corp Admin",
    "creator_email": "admin@acme.com",
    "difficulty_level": "high",
    "image_path": null,
    "price": 299.99,
    "access_period_months": null,
    "available_slots": null,
    "campus_hiring": null,
    "sponsored": true,
    "minimum_score": null,
    "experience_from": null,
    "experience_to": null,
    "locations": null,
    "employer_name": "Acme Corp",
    "created_at": "2024-04-01T10:00:00.000Z",
    "updated_at": "2024-04-10T10:00:00.000Z",
    "enrollment_count": 2,
    "module_count": 1,
    "topic_count": 2,
    "assessment_count": 0
  }
]
```

---

## View Course Content With Progress

**GET** `/api/course-content-with-progress?learning_program_tid=3001&user_tid=2001`

**Description:** Get course content and progress for a user.

**Success Response:**
```json
[
  {
    "course_id": 3001,
    "course_title": "Advanced SQL Bootcamp",
    "course_description": "A deep dive into SQL procedures.",
    "difficulty_level": "high",
    "image_path": null,
    "overall_progress_percentage": 50,
    "enrollment_status": "in_progress"
  },
  // ... modules and topics with progress ...
]
```

---

**How to use in Postman:**
- Set the request type (GET, POST, PUT, DELETE).
- For POST/PUT/DELETE, set the body to `raw` and `JSON`.
- For GET, use query parameters or path parameters as shown.
- Set the URL to `http://localhost:3000` (or your server's address) plus the endpoint. 