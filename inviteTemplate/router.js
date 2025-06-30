const express = require('express');
const app = express();
const inviteRouter = express.Router();
const listInviteTemplates = require('./list-ctrl');

inviteRouter.get('/list-invite-template',listInviteTemplates);

module.exports = inviteRouter;