const express = require('express');
const router = express.Router();
const addTopicAssessment = require('../../controllers/learningController/topicAssessmentController');
const submitTopicAssessment = require('../../controllers/learningController/topicAssessmentResponseController');

router.post('/topic-assessment', addTopicAssessment);
router.post('/submit-topic-assessment', submitTopicAssessment);

module.exports = router;