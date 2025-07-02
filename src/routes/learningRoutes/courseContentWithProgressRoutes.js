const express = require('express');
const router = express.Router();
const courseContentWithProgressController = require('../../controllers/learningController/courseContentWithProgressController');

router.get('/', courseContentWithProgressController.viewCourseContentWithProgress);

module.exports = router; 