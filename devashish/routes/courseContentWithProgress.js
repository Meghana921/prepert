const express = require('express');
const router = express.Router();
const courseContentWithProgressController = require('../controllers/courseContentWithProgressController');

router.get('/', courseContentWithProgressController.viewCourseContentWithProgress);

module.exports = router; 