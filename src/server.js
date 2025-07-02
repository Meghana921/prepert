const express = require("express");
const app = express();
const { testConnection, pool } = require("./config/db");
testConnection();

app.use(express.json());

// Learning module routes
app.use('/api/learning/programs', require('./routes/learningRoutes/programRoutes'));
app.use('/api/learning/eligibility', require('./routes/learningRoutes/eligibilityTemplateRoutes'));
app.use('/api/learning/assessment', require('./routes/learningRoutes/assessmentRoutes'));
app.use('/api/learning/user', require('./routes/learningRoutes/userRoutes'));
app.use('/api/learning/learning-question', require('./routes/learningRoutes/learningQuestionRoutes'));
app.use('/api/learning/track-progress', require('./routes/learningRoutes/trackProgressRoutes'));
app.use('/api/learning/company-subscribers', require('./routes/learningRoutes/companySubscribersRoutes'));
app.use('/api/learning/courses', require('./routes/learningRoutes/coursesRoutes'));
app.use('/api/learning/course-content', require('./routes/learningRoutes/courseContentRoutes'));
app.use('/api/learning/course-content-with-progress', require('./routes/learningRoutes/courseContentWithProgressRoutes'));
app.use('/api/learning/invite-template', require('./routes/learningRoutes/inviteTemplateRoutes'));

app.listen(3000);
