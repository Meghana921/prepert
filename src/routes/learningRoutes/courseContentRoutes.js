import express from "express";
import addLearningModulesAndTopics from '../../controllers/learningController/addCourseContent.js';
import viewCourseContentController from '../../controllers/learningController/viewCourseContent.js';
import updateCourseContent from '../../controllers/learningController/updateCourseContent.js';
import viewProgramWithProgress from '../../controllers/learningController/getCourseContent.js';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
const router = express.Router();

router.post('/add-course-content', addLearningModulesAndTopics);
router.get('/view-course-content', viewCourseContentController);
router.put('/update-course-content',updateCourseContent);
router.get('/get-course-content',viewProgramWithProgress);
export default router; 