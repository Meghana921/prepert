import { createTransport } from 'nodemailer';

const sendMail = async ({ to, subject, text, html, programId, recipientName }) => {
  try {
    const signature = `
      <p>
        Click here to enroll for the course:
        <a href="https://prepert.vercel.app/" target="_blank">https://prepert.vercel.app/</a>
      </p>
      <br/>
      <p style="font-size: 14px; color: #555;">
        Best regards,<br/>
        <strong>Talent Micro</strong>
      </p>
    `;

    const mailBody = html || `
      <p>Dear ${recipientName || 'Candidate'},</p>
      <p>${text}</p>
      ${signature}
    `;

    const transporter = createTransport({
      service: 'gmail',
      auth: {
        user: process.env.SERVER_EMAIL,
        pass: process.env.SERVER_PASSWORD,
      },
    });

    const mailOptions = {
      from: process.env.SERVER_EMAIL,
      to,
      subject,
      html: mailBody,
    };

    await transporter.sendMail(mailOptions);
  } catch (error) {
    console.error("Email sending error:", error);
    throw new Error('Failed to send email');
  }
};

export default sendMail;
