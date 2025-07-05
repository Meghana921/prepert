import express from "express";
import addTopicAssessment from '../../controllers/learningController/topicAssessmentController.js';
import submitTopicAssessment from '../../controllers/learningController/topicAssessmentResponseController.js';
import addProgramAssessment from '../../controllers/learningController/addProgramAssessmentController.js';
import viewProgramassessment from '../../controllers/learningController/viewProgramAssessmentController.js';
import submitProgramAssessment from '../../controllers/learningController/programAssessmentResponseController.js';
import editProgramAssessment from '../../controllers/learningController/updateProgramAssessment.js';

const router = express.Router();

router.post('/topic-assessment', addTopicAssessment);
router.post('/submit-topic-assessment', submitTopicAssessment);
router.post('/add-program-assessment', addProgramAssessment);
router.get('/view-program-assessment', viewProgramassessment);
router.post('/submit-program-assessment', submitProgramAssessment);
router.put('/update-program-assessment', editProgramAssessment);

export default router;


