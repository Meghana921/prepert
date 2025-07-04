import express from "express";
import coursesController from '../../controllers/learningController/coursesController.js';
const router = express.Router();

router.get('/', coursesController);

export default router; 