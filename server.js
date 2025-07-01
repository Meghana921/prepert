const express = require("express");
const app = express();
const { testConnection, pool } = require("./db");
const programRouter = require("./program/router");
const eTemplateRouter = require("./eTemplate/router");
const inviteRouter = require('./inviteTemplate/router')
const assessmentRouter = require('./assessment/router')
testConnection();

app.use(express.json());
app.use("/", programRouter);
app.use("/",eTemplateRouter);
app.use("/",inviteRouter);
app.use("/",assessmentRouter);
app.listen(3000);
