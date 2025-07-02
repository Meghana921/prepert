# prepert-backend-v1
prepert backend node application

Project Strucutre

prepert-backend/
├── src/
│   ├── config/          # Configuration (DB, environment, constants)
│   │   ├── db.js
│   │   ├── env.js
│   ├── models/          # Database models & queries
│   │   ├── userModel.js
│   │   ├── postModel.js
│   ├── controllers/     # Route logic handlers
│   │   ├── userController.js
│   │   ├── postController.js
│   ├── routes/          # API routes
│   │   ├── userRoutes.js
│   │   ├── postRoutes.js
│   ├── middlewares/     # Auth, error handling, validation
│   │   ├── authMiddleware.js
│   │   ├── errorMiddleware.js
│   │   └── validate.js
│   ├── services/        # Business logic, reusable services
│   │   ├── userService.js
│   │   └── postService.js
│   ├── utils/           # Helper functions, custom error classes
│   │   ├── logger.js
│   │   └── ApiError.js
│   ├── app.js           # Express app config
│   └── server.js        # Entry point
├── .env                 # Environment variables
├── .gitignore
├── package.json
├── README.md
└── sql/                 # DB schema scripts
    ├── init.sql
