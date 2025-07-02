const express = require('express');
const router = express.Router();
const userController = require('../../controllers/learningController/userController');

router.get('/:user_tid/subscribed-courses', userController.listSubscribedCourses);

module.exports = router; 