import { createTransport } from 'nodemailer';

const sendMail = async ({ to, subject, text, html, programId, recipientName }) => {
  try {
    const baseUrl = "";

    const acceptLink = `${baseUrl}?program_id=${programId}&email=${to}&response=accept`;
    const declineLink = `${baseUrl}?program_id=${programId}&email=${to}&response=decline`;

    const buttons = `
      <div style="margin: 20px 0;">
        <a href="${acceptLink}" style="background-color: #4CAF50; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px; margin-right: 10px;">Accept</a>
        <a href="${declineLink}" style="background-color: #f44336; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px;">Decline</a>
      </div>
    `;

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
      ${buttons}
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
