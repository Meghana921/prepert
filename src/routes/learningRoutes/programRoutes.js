import express from "express";
import addProgram  from "../../controllers/learningController/addProgramController.js";
import view_created_programs from "../../controllers/learningController/listProgramsController.js";
import view_program from "../../controllers/learningController/viewProgramController.js";
import enrollment from "../../controllers/learningController/enrollmentController.js";
import updateLearningProgram from "../../controllers/learningController/updateProgramController.js";

const program_router = express.Router();

program_router.post("/create-program", addProgram);
program_router.get("/list-programs", view_created_programs);
program_router.get("/view-program", view_program);
program_router.post("/program-enrollment", enrollment);
program_router.post("/update-program", updateLearningProgram);

export default program_router;
