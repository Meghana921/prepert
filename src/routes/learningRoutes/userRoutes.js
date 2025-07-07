import express from "express";
import userController from "../../controllers/learningController/userController.js";
const router = express.Router();

router.get('/subscribed-courses', userController);

export default router; 