import express from "express";
import trackProgressController from "../../controllers/learningController/trackProgressController.js";
const router = express.Router();

router.post('/', trackProgressController);

export default router; 