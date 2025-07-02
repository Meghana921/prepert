const express = require("express");
const app = express();
const { testConnection, pool } = require("./db");
const programRouter = require("./meghana/program/router");
const eTemplateRouter = require("./meghana/eligibilityTemplate/router");
const inviteRouter = require('./bheemadevaDatta/inviteTemplate/router');
const assessmentRouter = require('./meghana/assessment/router');
testConnection();

//devashish
app.use(express.json());
app.use('/api/course-content', require('./devashish/routes/courseContent'));
app.use('/api/learning-question', require('./devashish/routes/learningQuestion'));
app.use('/api/invite', require('./devashish/routes/invite'));
app.use('/api/track-progress', require('./devashish/routes/trackProgress'));
app.use('/api/user', require('./devashish/routes/user'));
app.use('/api/company-subscribers', require('./devashish/routes/companySubscribers'));
app.use('/api/courses', require('./devashish/routes/courses'));
app.use('/api/course-content-with-progress', require('./devashish/routes/courseContentWithProgress'));
app.use('/api/invites', require('./devashish/routes/invites'));

//meghana
app.use("/", programRouter);
app.use("/",eTemplateRouter);
app.use("/",assessmentRouter);

//bheemadevadatta
app.use("/",inviteRouter);


app.listen(3000);
