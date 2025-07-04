import nodemailer from 'nodemailer';
import dotenv from 'dotenv';
dotenv.config();

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST || 'smtp.gmail.com',
  port: process.env.EMAIL_PORT ? parseInt(process.env.EMAIL_PORT) : 587,
  secure: process.env.EMAIL_SECURE === 'true', // true for 465
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
  if (!templateContent || typeof templateContent !== 'string') {
    console.error('❌ templateContent is invalid or undefined:', templateContent);
    throw new Error('Email template content is missing or not a string');
  }

  // Safe string replacement
  const htmlContent = templateContent
    .replace(/{{name}}/g, name || '')
    .replace(/{{programTitle}}/g, programTitle || '');

  const mailOptions = {
    from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
    to,
    subject: `Invitation to join: ${programTitle || 'our program'}`,
    html: htmlContent,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email sent:', info.messageId);
    return info;
  } catch (error) {
    console.error('❌ Error sending email:', error);
    throw error;
  }
}

export default sendEmail;
