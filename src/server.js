import express from "express";
import { testConnection, pool } from "./config/db.js";
import programRoutes from "./routes/learningRoutes/programRoutes.js";
import eligibilityTemplateRoutes from "./routes/learningRoutes/eligibilityTemplateRoutes.js";
import assessmentRoutes from "./routes/learningRoutes/assessmentRoutes.js";
import userRoutes from "./routes/learningRoutes/userRoutes.js";
import learningQuestionRoutes from "./routes/learningRoutes/learningQuestionRoutes.js";
import trackProgressRoutes from "./routes/learningRoutes/trackProgressRoutes.js";
import companySubscribersRoutes from "./routes/learningRoutes/companySubscribersRoutes.js";
import coursesRoutes from "./routes/learningRoutes/coursesRoutes.js";
import courseContentRoutes from "./routes/learningRoutes/courseContentRoutes.js";
import courseContentWithProgressRoutes from "./routes/learningRoutes/courseContentWithProgressRoutes.js";
import inviteTemplateRoutes from "./routes/learningRoutes/inviteTemplateRoutes.js";
import getCertificateRoutes from "./routes/learningRoutes/getCertificateRoutes.js";
import enrollmentRoute from "./routes/learningRoutes/enrollementRoute.js"
testConnection();

const app = express();
app.use(express.json());

// Learning module routes
app.use('/learning', programRoutes);
app.use('/learning', eligibilityTemplateRoutes);
app.use('/learning', assessmentRoutes);
app.use('/learning',enrollmentRoute);
app.use('/api/learning/user', userRoutes);
app.use('/learning', learningQuestionRoutes);
app.use('/api/learning/track-progress', trackProgressRoutes);
app.use('/learning', companySubscribersRoutes);
app.use('/api/learning/courses', coursesRoutes);
app.use('/learning', courseContentRoutes);
app.use('/api/learning/course-content-with-progress', courseContentWithProgressRoutes);
app.use('/learning', inviteTemplateRoutes);
app.use('/api/learning/get-certificate', getCertificateRoutes);

app.listen(3000);
