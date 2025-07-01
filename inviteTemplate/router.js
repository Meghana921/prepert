const express = require('express');
const app = express();
const inviteRouter = express.Router();
const addInviteTemplate = require('./controller/add-ctrl');
const listInviteTemplates = require('./controller/list-ctrl');
const updateInviteTemplate = require('./controller/update-ctrl');
const viewInviteTemplate = require('./controller/view-ctrl');

inviteRouter.get('/list-invite-template',listInviteTemplates);
inviteRouter.post('/add-invite-template',addInviteTemplate);
inviteRouter.post('/update-invite-template',updateInviteTemplate);
inviteRouter.get('/view-invite-template',viewInviteTemplate);


module.exports = inviteRouter;