import express from "express";
import learningQuestionController from "../../controllers/learningController/learningQuestionController.js";
const router = express.Router();

router.post('/', learningQuestionController);

export default router; 