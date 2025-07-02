const express = require('express');
const app = express();
const assessmentRouter = express.Router();
const addTopicAssessment = require('./controller/topic-assessment-ctrl');
const submitTopicAssessment = require('./controller/topic-assessment-response');
assessmentRouter.post('/topic-assessment', addTopicAssessment);
assessmentRouter.post('/submit-topic-assessment', submitTopicAssessment);


module.exports = assessmentRouter;