import express from "express";
import courseContentWithProgressController from '../../controllers/learningController/courseContentWithProgressController.js';
const router = express.Router();

router.get('/', courseContentWithProgressController);

export default router; 