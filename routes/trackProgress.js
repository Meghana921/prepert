const express = require('express');
const router = express.Router();
const trackProgressController = require('../controllers/trackProgressController');

router.post('/', trackProgressController.trackProgress);

module.exports = router; 