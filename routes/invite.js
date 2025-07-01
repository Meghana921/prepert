const express = require('express');
const router = express.Router();
const inviteController = require('../controllers/inviteController');

router.post('/', inviteController.sendInvite);

module.exports = router; 