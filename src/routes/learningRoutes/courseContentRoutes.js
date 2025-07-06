import express from "express";
import addLearningModulesAndTopics from '../../controllers/learningController/addCourseContent.js';
import viewCourseContentController from '../../controllers/learningController/viewCourseContent.js';
// import updateCourseContent from "../../controllers/learningController/updateCourseContent.js"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
const router = express.Router();

router.post('/add-course-content', addLearningModulesAndTopics);
router.get('/view-course-content', viewCourseContentController);
// router.delete('/update-course-content', updateCourseContent);
export default router; 