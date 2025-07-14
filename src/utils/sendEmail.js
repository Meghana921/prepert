import { createTransport } from 'nodemailer';

const sendMail = async ({
  to,
  subject,
  text,
  html,
  programCode,
  programTitle,
  recipientName
}) => {
  try {
    const programLink = `https://prepert.vercel.app`;

    const signature = `
      <p>
        <a href="${programLink}" target="_blank" style="text-decoration:none; color:#3366cc;">
          👉 Click here to view invitation
        </a>
      </p>
      <p><strong>Program Title:</strong> ${programTitle || 'N/A'}</p>
      <p><strong>Program Code:</strong> ${programCode || 'N/A'}</p>
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
        user: process.env.SERVER_EMAIL || "talent.micro01@gmail.com",
        pass: process.env.SERVER_PASSWORD || "bwegpjkyiaclwoya",
      },
    });

    const mailOptions = {
      from: `"Talent Micro" <${process.env.SERVER_EMAIL}>`,
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

