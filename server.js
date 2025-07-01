const express = require("express");
const app = express();
const { testConnection, pool } = require("./db");
const programRouter = require("./program/router");
const eTemplateRouter = require("./eTemplate/router");
const inviteRouter = require('./inviteTemplate/router')
const assessmentRouter = require('./assessment/router')

testConnection();

app.use(express.json());
app.use('/api/course-content', require('./routes/courseContent'));
app.use('/api/learning-question', require('./routes/learningQuestion'));
app.use('/api/invite', require('./routes/invite'));
app.use('/api/track-progress', require('./routes/trackProgress'));
app.use('/api/user', require('./routes/user'));
app.use('/api/company-subscribers', require('./routes/companySubscribers'));
app.use('/api/courses', require('./routes/courses'));
app.use('/api/course-content-with-progress', require('./routes/courseContentWithProgress'));
app.use('/api/invites', require('./routes/invites'));
app.use("/", programRouter);
app.use("/",eTemplateRouter);
app.use("/",inviteRouter);
app.use("/",assessmentRouter);
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  }); 
