import Router from "express";
import addProgram  from "../../controllers/learningController/addProgramController.js";
import view_created_programs from "../../controllers/learningController/listCreatedProgramsController.js";
import view_program from "../../controllers/learningController/viewProgramController.js";
import enrollment from "../../controllers/learningController/enrollmentController.js";
import updateLearningProgram from "../../controllers/learningController/updateProgramController.js";
// import deleteLearningProgram from "../../controllers/learningController/deleteProgram.js"
import addSponsorship from "../../controllers/learningController/addSponsorship.js";
import updateSponsorship from "../../controllers/learningController/updateSponsorship.js";
const router = Router();

router.post("/create-program", addProgram);
router.get("/list-programs", view_created_programs);
router.get("/view-program", view_program);
router.post("/program-enrollment", enrollment);
router.put("/update-program", updateLearningProgram);
// router.delete("/delete-program",deleteLearningProgram)
router.post("/add-sponsorship" , addSponsorship);
router.put("/update-sponsorship" , updateSponsorship);

export default router;
