import express from 'express';
import { getCertificate } from '../../controllers/learningController/getCertificateController.js';

const router = express.Router();

router.get('/get-certificate', getCertificate);

export default router;