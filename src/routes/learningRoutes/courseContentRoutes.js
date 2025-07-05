import express from "express";
import addLearningModulesAndTopics from '../../controllers/learningController/addCourseContent.js';
import viewCourseContentController from '../../controllers/learningController/viewCourseContent.js'
const router = express.Router();

router.post('/add-course-content', addLearningModulesAndTopics);
router.get('/view-course-content', viewCourseContentController);
// router.delete('/', courseContentController.deleteCourseContent);

export default router; 