import express from "express";
import trackProgressController from "../../controllers/learningController/trackProgressController.js";
const router = express.Router();

router.post('/track-course-progress', trackProgressController);

export default router; 