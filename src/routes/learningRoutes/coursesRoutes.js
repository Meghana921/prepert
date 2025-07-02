const express = require('express');
const router = express.Router();
const coursesController = require('../../controllers/learningController/coursesController');

router.get('/', coursesController.listCourses);

module.exports = router; 