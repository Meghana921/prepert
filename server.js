const express = require("express");
const app = express();
const { testConnection, pool } = require("./db");
const programRouter = require("./meghana/program/router");
const eTemplateRouter = require("./meghana/eTemplate/router");
const inviteRouter = require('./bheemadevaDatta/inviteTemplate/router');
const assessmentRouter = require('./meghana/assessment/router');
testConnection();

app.use(express.json());
app.use("/", programRouter);
app.use("/",eTemplateRouter);
app.use("/",inviteRouter);
app.use("/",assessmentRouter);
app.listen(3000);
