const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST || 'smtp.gmail.com',
  port: process.env.EMAIL_PORT ? parseInt(process.env.EMAIL_PORT) : 587,
  secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
  tls: {
    rejectUnauthorized: false,
  },
});

/**
 * Send an email to the invitee
 * @param {Object} param0
 * @param {string} param0.to - Recipient email address
 * @param {string} param0.name - Recipient name
 * @param {string} param0.programTitle - Program title
 * @param {string} param0.templateContent - Email HTML content
 */
async function sendEmail({ to, name, programTitle, templateContent }) {
  const mailOptions = {
    from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
    to,
    subject: `Invitation to join: ${programTitle}`,
    html: templateContent.replace(/{{name}}/g, name).replace(/{{programTitle}}/g, programTitle),
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent:', info.messageId);
    return info;
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
}

module.exports = sendEmail; 