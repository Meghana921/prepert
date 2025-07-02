const express = require('express');
const router = express.Router();
const addTopicAssessment = require('../../controllers/learningController/topicAssessmentController');
const submitTopicAssessment = require('../../controllers/learningController/topicAssessmentResponseController');
const addProgramAssessment = require('../../controllers/learningController/addProgramAssessmentController');
const viewProgramassessment = require('../../controllers/learningController/viewProgramAssessmentController');
const submitProgramAssessment = require('../../controllers/learningController/programAssessmentResponseController');
const editProgramAssessment = require('../../controllers/learningController/editProgramAssessment');


router.post('/topic-assessment', addTopicAssessment);
router.post('/submit-topic-assessment', submitTopicAssessment);
router.post('/program-assessment',addProgramAssessment);
router.get('/view-program-assesment',viewProgramassessment);
router.post('/submit-program-assessment-response',submitProgramAssessment);
router.post('/edit-program-assessment',editProgramAssessment);

module.exports = router;


