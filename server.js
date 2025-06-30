const express = require("express");
const app = express();
const { testConnection, pool } = require("./db");
const programRouter = require("./program/program-route");
const eTemplateRouter = require("./eTemplate/router");
const inviteRouter = require('./inviteTemplate/router')
testConnection();

app.use(express.json());
app.use("/", programRouter);
app.use("/",eTemplateRouter);
app.use("/",inviteRouter);
app.listen(3000);
