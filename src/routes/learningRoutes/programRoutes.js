const express = require("express");
const program_router = express.Router();
const add_program = require("../../controllers/learningController/addProgramController.js");
const view_created_programs = require("../../controllers/learningController/listProgramsController.js");
const view_program = require("../../controllers/learningController/viewProgramController.js");
const enrollment = require("../../controllers/learningController/enrollmentController.js");
const updateLearningProgram = require("../../controllers/learningController/updateProgramController.js");

program_router.post("/create-program", add_program);
program_router.get("/list-programs", view_created_programs);
program_router.get("/view-program", view_program);
program_router.post("/program-enrollment", enrollment);
program_router.post("/update-program", updateLearningProgram);

module.exports = program_router;
