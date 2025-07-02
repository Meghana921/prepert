# prepert-backend-v1
prepert backend node application

Project Strucutre

```
prepert-backend/
├── src/
│   ├── config/          # Configuration (DB, environment, constants)
│   │   ├── db.js
│   │   ├── env.js
│   ├── models/          # Database models & queries
│   │   ├── interviewModel.js
│   │   ├── learningModel.js
│   │   ├── mockInterviewModel.js
│   │   ├── screeningModel.js
│   │   ├── userModel.js
│   ├── controllers/     # Route logic handlers
│   │   ├── interviewController.js
│   │   ├── learningController.js
│   │   ├── mockInterviewController.js
│   │   ├── screeningController.js
│   │   ├── userController.js
│   ├── routes/          # API routes
│   │   ├── interviewRoutes.js
│   │   ├── learningRoutes.js
│   │   ├── mockinterviewRoutes.js
│   │   ├── screeningRoutes.js
│   │   ├── userRoutes.js
│   ├── middlewares/     # Auth, error handling, validation
│   │   ├── authMiddleware.js
│   │   ├── errorMiddleware.js
│   │   └── validate.js
│   ├── services/        # Business logic, reusable services
│   │   └── interviewService.js
│   │   └── learningService.js
│   │   └── mockInterviewService.js
│   │   ├── screeningService.js
│   │   ├── userService.js
│   ├── utils/           # Helper functions, custom error classes
│   │   ├── logger.js
│   │   └── ApiError.js
│   ├── app.js           # Express/Fastify app config
│   └── server.js        # Entry point
├── .env                 # Environment variables
├── .gitignore
├── package.json
├── README.md
└── sql/                 # DB schema scripts
    ├── init.sql
    ├── interview.sql
    ├── learning.sql
    ├── mockInterview.sql
    ├── screening.sql
    ├── user.sql
```
