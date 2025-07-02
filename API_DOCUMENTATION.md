# Learning Module API Documentation

**Base URL:** `/api/learning`

---

## Programs

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| POST   | `/programs/create-program`      | Create a new program                | addProgramController       |
| GET    | `/programs/list-programs`       | List all created programs           | listProgramsController     |
| GET    | `/programs/view-program`        | View a specific program             | viewProgramController      |
| POST   | `/programs/program-enrollment`  | Enroll in a program                 | enrollmentController       |
| POST   | `/programs/update-program`      | Update a program                    | updateProgramController    |

### Examples

#### POST `/programs/create-program`
**Request Body:**
```json
{
  "title": "JavaScript Bootcamp",
  "description": "Learn JS from scratch",
  "creator_id": 1,
  "difficulty_level": "Beginner",
  "price": 100,
  "access_period_months": 6
}
```
**Response:**
```json
{
  "success": true,
  "program_id": 123
}
```

#### GET `/programs/list-programs`
**Response:**
```json
[
  {
    "program_id": 123,
    "title": "JavaScript Bootcamp",
    "creator_id": 1
  },
  {
    "program_id": 124,
    "title": "Python Basics",
    "creator_id": 2
  }
]
```

#### GET `/programs/view-program?program_id=123`
**Response:**
```json
{
  "program_id": 123,
  "title": "JavaScript Bootcamp",
  "description": "Learn JS from scratch",
  "creator_id": 1,
  "difficulty_level": "Beginner",
  "price": 100,
  "access_period_months": 6
}
```

#### POST `/programs/program-enrollment`
**Request Body:**
```json
{
  "user_id": 10,
  "program_id": 123
}
```
**Response:**
```json
{
  "success": true,
  "message": "Enrolled successfully"
}
```

#### POST `/programs/update-program`
**Request Body:**
```json
{
  "program_id": 123,
  "title": "Advanced JS Bootcamp"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Program updated"
}
```

---

## Eligibility Templates

| Method | Endpoint                        | Description                        | Controller Function                |
|--------|---------------------------------|------------------------------------|------------------------------------|
| POST   | `/eligibility/add-eligibility-template`    | Add a new eligibility template     | addEligibilityController           |
| GET    | `/eligibility/list-eligibility-template`   | List all eligibility templates     | listEligibilityController          |
| POST   | `/eligibility/update-eligibility-template` | Update an eligibility template     | updateEligibilityController        |
| GET    | `/eligibility/view-eligibility-template`   | View an eligibility template       | viewEligibilityController          |
| POST   | `/eligibility/submit-eligibility-response` | Submit eligibility response        | eligibilityResponseController      |

### Examples

#### POST `/eligibility/add-eligibility-template`
**Request Body:**
```json
{
  "name": "Graduate Eligibility",
  "criteria": ["Bachelors Degree", "Minimum 60% marks"]
}
```
**Response:**
```json
{
  "success": true,
  "template_id": 55
}
```

#### GET `/eligibility/list-eligibility-template`
**Response:**
```json
[
  { "template_id": 55, "name": "Graduate Eligibility" },
  { "template_id": 56, "name": "Postgraduate Eligibility" }
]
```

#### POST `/eligibility/update-eligibility-template`
**Request Body:**
```json
{
  "template_id": 55,
  "name": "Updated Graduate Eligibility"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Template updated"
}
```

#### GET `/eligibility/view-eligibility-template?template_id=55`
**Response:**
```json
{
  "template_id": 55,
  "name": "Graduate Eligibility",
  "criteria": ["Bachelors Degree", "Minimum 60% marks"]
}
```

#### POST `/eligibility/submit-eligibility-response`
**Request Body:**
```json
{
  "user_id": 10,
  "template_id": 55,
  "response": "Eligible"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Response submitted"
}
```

---

## Assessment

| Method | Endpoint                        | Description                        | Controller Function                |
|--------|---------------------------------|------------------------------------|------------------------------------|
| POST   | `/assessment/topic-assessment`           | Add a topic assessment             | topicAssessmentController          |
| POST   | `/assessment/submit-topic-assessment`    | Submit a topic assessment          | topicAssessmentResponseController  |

### Examples

#### POST `/assessment/topic-assessment`
**Request Body:**
```json
{
  "program_id": 123,
  "topic": "Functions",
  "questions": [
    { "question": "What is a closure?", "type": "short-answer" }
  ]
}
```
**Response:**
```json
{
  "success": true,
  "assessment_id": 77
}
```

#### POST `/assessment/submit-topic-assessment`
**Request Body:**
```json
{
  "assessment_id": 77,
  "user_id": 10,
  "answers": [
    { "question_id": 1, "answer": "A closure is..." }
  ]
}
```
**Response:**
```json
{
  "success": true,
  "score": 8
}
```

---

## User

| Method | Endpoint                                  | Description                        | Controller Function         |
|--------|-------------------------------------------|------------------------------------|----------------------------|
| GET    | `/user/:user_tid/subscribed-courses`      | List courses a user is subscribed to| userController.listSubscribedCourses |

### Example

#### GET `/user/10/subscribed-courses`
**Response:**
```json
[
  { "course_id": 1, "name": "JavaScript Bootcamp" },
  { "course_id": 2, "name": "Python Basics" }
]
```

---

## Invites

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| POST   | `/invite/`              | Send an invite                     | invitesController.sendInvite|
| POST   | `/invites/`             | Send an invite                     | invitesController.sendInvite|
| POST   | `/invites/redeem`       | Redeem an invite                   | invitesController.redeemInvite|

### Examples

#### POST `/invite/`
**Request Body:**
```json
{
  "email": "user@example.com",
  "program_id": 123
}
```
**Response:**
```json
{
  "success": true,
  "invite_id": 99
}
```

#### POST `/invites/redeem`
**Request Body:**
```json
{
  "invite_code": "ABC123"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Invite redeemed"
}
```

---

## Learning Questions

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| POST   | `/learning-question/`   | Add a learning question            | learningQuestionController.addLearningQuestion |

### Example

#### POST `/learning-question/`
**Request Body:**
```json
{
  "program_id": 123,
  "question": "Explain event loop in JS?"
}
```
**Response:**
```json
{
  "success": true,
  "question_id": 5
}
```

---

## Track Progress

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| POST   | `/track-progress/`      | Track learning progress            | trackProgressController.trackProgress |

### Example

#### POST `/track-progress/`
**Request Body:**
```json
{
  "user_id": 10,
  "program_id": 123,
  "progress": 80
}
```
**Response:**
```json
{
  "success": true,
  "message": "Progress updated"
}
```

---

## Company Subscribers

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| GET    | `/company-subscribers/` | View company subscribers           | companySubscribersController.viewCompanySubscribers |

### Example

#### GET `/company-subscribers/`
**Response:**
```json
[
  { "user_id": 10, "name": "Alice" },
  { "user_id": 11, "name": "Bob" }
]
```

---

## Courses

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| GET    | `/courses/`             | List all courses                   | coursesController.listCourses |

### Example

#### GET `/courses/`
**Response:**
```json
[
  { "course_id": 1, "name": "JavaScript Bootcamp" },
  { "course_id": 2, "name": "Python Basics" }
]
```

---

## Course Content

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| POST   | `/course-content/`      | Add course content                 | courseContentController.addCourseContent |
| PUT    | `/course-content/`      | Edit course content                | courseContentController.editCourseContent |
| DELETE | `/course-content/`      | Delete course content              | courseContentController.deleteCourseContent |

### Examples

#### POST `/course-content/`
**Request Body:**
```json
{
  "course_id": 1,
  "title": "Introduction",
  "content": "Welcome to the course!"
}
```
**Response:**
```json
{
  "success": true,
  "content_id": 101
}
```

#### PUT `/course-content/`
**Request Body:**
```json
{
  "content_id": 101,
  "title": "Intro Updated"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Content updated"
}
```

#### DELETE `/course-content/`
**Request Body:**
```json
{
  "content_id": 101
}
```
**Response:**
```json
{
  "success": true,
  "message": "Content deleted"
}
```

---

## Course Content With Progress

| Method | Endpoint                | Description                        | Controller Function         |
|--------|-------------------------|------------------------------------|----------------------------|
| GET    | `/course-content-with-progress/` | View course content with progress | courseContentWithProgressController.viewCourseContentWithProgress |

### Example

#### GET `/course-content-with-progress/`
**Response:**
```json
[
  { "content_id": 101, "title": "Introduction", "progress": 100 },
  { "content_id": 102, "title": "Advanced", "progress": 60 }
]
```

---

## Invite Templates

| Method | Endpoint                        | Description                        | Controller Function                |
|--------|---------------------------------|------------------------------------|------------------------------------|
| GET    | `/invite-template/list-invite-template`   | List all invite templates          | listInviteTemplateController       |
| POST   | `/invite-template/add-invite-template`    | Add a new invite template          | addInviteTemplateController        |
| POST   | `/invite-template/update-invite-template` | Update an invite template          | updateInviteTemplateController     |
| GET    | `/invite-template/view-invite-template`   | View an invite template            | viewInviteTemplateController       |

### Examples

#### GET `/invite-template/list-invite-template`
**Response:**
```json
[
  { "template_id": 1, "name": "Default Invite" },
  { "template_id": 2, "name": "Special Invite" }
]
```

#### POST `/invite-template/add-invite-template`
**Request Body:**
```json
{
  "name": "Special Invite",
  "content": "You are invited!"
}
```
**Response:**
```json
{
  "success": true,
  "template_id": 2
}
```

#### POST `/invite-template/update-invite-template`
**Request Body:**
```json
{
  "template_id": 2,
  "name": "Special Invite Updated"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Template updated"
}
```

#### GET `/invite-template/view-invite-template?template_id=2`
**Response:**
```json
{
  "template_id": 2,
  "name": "Special Invite",
  "content": "You are invited!"
}
```

---

**General Notes:**
- All endpoints are prefixed with `/api/learning/` as per your `server.js`.
- Controller function names are inferred from the route files and may need to be confirmed for exact handler names.
- For endpoints with dynamic parameters (e.g., `:user_tid`), replace with actual values in requests.
- All request/response examples are in JSON and ready for use in Postman. 