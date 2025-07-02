const express = require('express');
const router = express.Router();
const companySubscribersController = require('../../controllers/learningController/companySubscribersController');

router.get('/', companySubscribersController.viewCompanySubscribers);

module.exports = router; 