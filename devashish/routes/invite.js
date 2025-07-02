const express = require('express');
const router = express.Router();
const inviteController = require('../controllers/invitesController');

router.post('/', inviteController.sendInvite);

module.exports = router; 