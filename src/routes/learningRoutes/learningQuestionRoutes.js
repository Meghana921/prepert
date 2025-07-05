import express from "express";
import learningQuestionController from "../../controllers/learningController/learningQuestionController.js";
const router = express.Router();

router.post('/add-learning-questions', learningQuestionController);

export default router; 