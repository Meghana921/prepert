const db = require('../../db');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
require('dotenv').config();

const INVITE_SECRET = process.env.INVITE_SECRET || 'supersecret';
const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

// Utility: Generate a secure invite code
function generateInviteCode(email, programId) {
  return jwt.sign({ email, programId }, INVITE_SECRET, { expiresIn: '7d' });
}

// Utility: Decode and verify invite code
function decodeInviteCode(code) {
  return jwt.verify(code, INVITE_SECRET);
}
const createTransporter = () => {
    return nodemailer.createTransport({
        host: process.env.EMAIL_HOST || 'smtp.gmail.com',
        port: process.env.EMAIL_PORT || 587,
        secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASS
        },
        tls: {
            rejectUnauthorized: false
        }
    });
};
// Utility: Send invite email
async function sendInviteEmail(email, code, programId) {
  const transporter =  createTransporter();

  const mailOptions = {
    from: process.env.SMTP_FROM,
    to: email,
    subject: 'You are invited to join a learning program!',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Learning Program Invitation</h2>
        <p>Hello!</p>
        <p>You have been invited to join a learning program. Here are your details:</p>
        <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <p><strong>Invite Code:</strong> <span style="font-family: monospace; background-color: #fff; padding: 5px; border: 1px solid #ddd;">${code}</span></p>
          <p><strong>Program ID:</strong> ${programId}</p>
        </div>
        <p>To enroll in the program:</p>
        <ol>
          <li>Register on our LMS platform</li>
          <li>Use the invite code above during enrollment</li>
          <li>Or click the link below to register and enroll directly</li>
        </ol>
        <p style="text-align: center; margin: 30px 0;">
          <a href="${BASE_URL}/register?code=${encodeURIComponent(code)}&program=${programId}" 
             style="background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Register & Enroll Now
          </a>
        </p>
        <p style="color: #666; font-size: 12px;">
          This invite code will expire in 7 days. If you have any questions, please contact support.
        </p>
      </div>
    `
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', info.messageId);
    return info;
  } catch (error) {
    console.error('Error sending email:', error);
    throw new Error('Failed to send invite email');
  }
}

exports.sendInvite = async (req, res) => {
  try {
    const { email, programId } = req.body;
    if (!email || !programId) {
      return res.status(400).json({ error: 'email and programId are required' });
    }
    const code = generateInviteCode(email, programId);
    // Store invite in DB
    await db.callProcedure('sp_create_or_update_invite_code', [email, programId, code]);
    await sendInviteEmail(email, code, programId);
    res.json({ success: true, code });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.redeemInvite = async (req, res) => {
  try {
    const { email, code, userId } = req.body;
    if (!email || !code || !userId) {
      return res.status(400).json({ error: 'email, code, and userId are required' });
    }
    let decoded;
    try {
      decoded = decodeInviteCode(code);
    } catch (e) {
      return res.status(400).json({ error: 'Invalid or expired code' });
    }
    if (decoded.email !== email) {
      return res.status(400).json({ error: 'Code does not match email' });
    }
    // Validate invite code in DB
    const result = await db.callProcedure('sp_validate_invite_code', [code, email, decoded.programId]);
    if (!result[0] || result[0].length === 0) {
      return res.status(400).json({ error: 'Invalid or already used invite code' });
    }
    // Redeem invite and enroll user
    await db.callProcedure('sp_redeem_invite_code', [code, email, decoded.programId, userId]);
    res.json({ success: true, programId: decoded.programId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
}; 