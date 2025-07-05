import express from "express";
import addLearningModulesAndTopics from '../../controllers/learningController/addCourseContent.js';
const router = express.Router();

router.post('/add-course-content', addLearningModulesAndTopics);
// router.put('/', courseContentController.editCourseContent);
// router.delete('/', courseContentController.deleteCourseContent);

export default router; 