const express = require('express');
const router = express.Router();
const learningQuestionController = require('../controllers/learningQuestionController');

router.post('/', learningQuestionController.addLearningQuestion);

module.exports = router; 