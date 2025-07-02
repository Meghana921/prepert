const express = require('express');
const router = express.Router();
const companySubscribersController = require('../controllers/companySubscribersController');

router.get('/', companySubscribersController.viewCompanySubscribers);

module.exports = router; 