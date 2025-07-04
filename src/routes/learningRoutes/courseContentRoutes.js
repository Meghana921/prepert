import express from "express";
import courseContentController from '../../controllers/learningController/courseContentController.js';
const router = express.Router();

router.post('/', courseContentController.addCourseContent);
router.put('/', courseContentController.editCourseContent);
router.delete('/', courseContentController.deleteCourseContent);

export default router; 