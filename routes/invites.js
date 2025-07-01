const express = require('express');
const router = express.Router();
const invitesController = require('../controllers/invitesController');

// Send invite: POST /api/invites
router.post('/', invitesController.sendInvite);
// Redeem invite: POST /api/invites/redeem
router.post('/redeem', invitesController.redeemInvite);

module.exports = router; 