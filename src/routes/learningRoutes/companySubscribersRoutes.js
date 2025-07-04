import express from "express";
import companySubscribersController from "../../controllers/learningController/companySubscribersController.js";
const router = express.Router();

router.get('/', companySubscribersController);

export default router; 