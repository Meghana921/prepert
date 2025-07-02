const express = require('express');
const router = express.Router();
const trackProgressController = require('../../controllers/learningController/trackProgressController');

router.post('/', trackProgressController.trackProgress);

module.exports = router; 