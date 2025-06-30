
const express = require('express');
const program_router = express.Router();
const add_program = require('./add-program-ctrl');
const view_created_programs = require("./list-programs-ctrl");
const view_program = require('./view-program-ctrl');
const enrollment = require("./enrollment-ctrl");
const updateLearningProgram = require("./update-program-ctrl");


program_router.post('/create-program',add_program);
program_router.get('/view-created-programs',view_created_programs);
program_router.get('/view-program',view_program);
program_router.post('/program-enrollment',enrollment);
program_router.post('/update-program',updateLearningProgram);
module.exports = program_router;