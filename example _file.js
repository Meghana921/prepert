import { createHash } from 'crypto';
import { hash, compare } from 'bcrypt';

import db from '../config/db.js';
import { sendMail } from '../utils/mail.js';
import { verifyGoogleIdToken } from '../utils/auth.js';
import { otpGenerator, otpVerifier, jwtGenerator } from '../utils/generate.js';

// Individual user signup
export async function individualSignup(req, res) {
  const googleAuthResult = await verifyGoogleIdToken(req.body.idToken);
  if (!googleAuthResult.success) {
    return res.status(401).json({ error: googleAuthResult.error });
  }
  const eid = createHash('sha256').update(req.body.idToken).digest('hex');
  const [[[{ msg: msg, uid: uid }]]] = await db.query(
    `CALL insert_user_individual(?, ?, ?, ?, ?, ?, ?)`,
    [
      req.body.full_name,
      googleAuthResult.payload.email,
      req.body.phone,
      req.body.country_code,
      googleAuthResult.payload.picture,
      googleAuthResult.payload.language,
      eid,
    ]
  );
  if (msg.startsWith('User already exists')) {
    return res.status(409).json({
      status: false,
      error: 'User already exists',
    });
  }
  if (msg.startsWith('Error')) {
    return res
      .status(500)
      .json({ status: false, error: 'Error registering user' + msg });
  }
  await db.query(`CALL insert_resume(?,?,?)`, [
    uid,
    req.body.resume_path,
    req.body.resume_name,
  ]);
  const { accessToken, hashed_token, iat } = await jwtGenerator(
    1,
    req.body.email
  );
  const expiry = new Date((iat + Number(process.env.JWT_EXPIRY)) * 1000);
  await db.query(`CALL insert_user_session(?, ?, ?, ?, ?, ?, ?, ?)`, [
    uid,
    hashed_token,
    Number(req.headers.device_type),
    req.headers.ip,
    req.headers.user_agent,
    expiry,
    req.body.gcmid,
    req.body.apnsid,
  ]);
  const [
    [[{ full_name, phone, country_code, profile_picture_url, language_code }]],
  ] = await db.query(`CALL get_individual_user_details(?)`, [uid]);
  const [[[resumes]]] = await db.query(`CALL get_resume(?)`, [uid]);
  await sendMail({
    to: googleAuthResult.payload.email,
    subject: 'Welcome to Prepert',
    text: `Hello ${req.body.full_name},\n\nThank you for signing up on Prepert! We're excited to have you on board.\n\nBest regards,\nThe Prepert Team`,
  });

  res.status(201).json({
    status: true,
    message: 'User registered successfully',
    data: {
      user: {
        user_type: 1,
        full_name,
        email: googleAuthResult.payload.email,
        phone,
        country_code,
        profile_picture_url,
        language_code,
        token: accessToken,
        resumes,
      },
    },
  });
}

// Individual user login
export async function individualLogin(req, res) {
  const googleAuthResult = await verifyGoogleIdToken(req.body.idToken);
  if (!googleAuthResult.success) {
    return res
      .status(401)
      .json({ status: false, error: googleAuthResult.error });
  }
  const [[[{ tid: uid }]]] = await db.query(`CALL get_user(?)`, [
    googleAuthResult.payload.email,
  ]);
  if (!uid) {
    return res.status(404).json({ status: false, error: 'User not found' });
  }
  const { accessToken, hashed_token, iat } = await jwtGenerator(
    1,
    req.body.email
  );
  const expiry = new Date((iat + Number(process.env.JWT_EXPIRY)) * 1000);

  await db.query('CALL insert_user_session(?, ?, ?, ?, ?)', [
    uid,
    hashed_token,
    Number(req.headers.device_type),
    req.headers.ip,
    req.headers.user_agent,
    expiry,
    req.body.gcmid,
    req.body.apnsid,
  ]);
  const [
    [[{ full_name, phone, country_code, profile_picture_url, language_code }]],
  ] = await db.query(`CALL get_individual_user_details(?)`, [uid]);
  const [[[resumes]]] = await db.query(`CALL get_resume(?)`, [uid]);
  res.status(200).json({
    message: 'User logged in successfully',
    data: {
      user: {
        user_type: 1,
        full_name,
        email: googleAuthResult.payload.email,
        phone,
        country_code,
        profile_picture_url,
        language_code,
        token: accessToken,
        resumes,
      },
    },
  });
}

// Update individual user profile
export async function updateProfileIndividual(req, res) {
  const [[[{ tid: uid }]]] = await db.query(`CALL get_user(?)`, [
    req.user.email,
  ]);
  await db.query(`CALL update_user_individual(?,?,?,?)`, [
    uid,
    req.body.full_name,
    req.body.phone,
    req.body.country_code,
  ]);
  res.status(200).json({
    status: true,
    message: 'Profile updated successfully',
  });
}

// Insert individual user resume
export async function insertResumeIndividual(req, res) {
  const [[[{ tid: uid }]]] = await db.query(`CALL get_user(?)`, [
    req.user.email,
  ]);
  await db.query(`CALL insert_resume(?,?,?)`, [
    uid,
    req.body.resume_name,
    req.body.resume_path,
  ]);
  res.status(200).json({
    status: true,
    message: 'Resume created successfully',
  });
}

// Update individual user resume
export async function updateResumeIndividual(req, res) {
  const [[[{ tid: uid }]]] = await db.query(`CALL get_user(?)`, [
    req.user.email,
  ]);
  await db.query(`CALL update_resume(?,?,?,?)`, [
    uid,
    req.body.resume_name,
    req.body.resume_path,
    req.body.is_primary,
  ]);
  res.status(200).json({
    status: true,
    message: 'Resume updated successfully',
  });
}

// Delete individual user resume
export async function deleteResumeIndividual(req, res) {
  await db.query(`CALL delete_resume(?)`, [req.body.rtid]);
  res.status(200).json({ message: 'Resume deleted successfully' });
}

// Company user signup
export async function companySignup(req, res) {
  const [[[{ msg: msg, uid: uid }]]] = await db.query(
    `CALL insert_user_company(?,?,?,?,?,?,?,?,?,?,?)`,
    [
      req.body.full_name,
      req.body.email,
      req.body.phone,
      req.body.country_code,
      req.body.profile_picture_url,
      req.body.company_name,
      req.body.job_title,
      req.body.website,
      req.body.language_code,
      req.body.work_phone,
      req.body.work_country_code,
    ]
  );
  if (msg.startsWith('Error')) {
    return res
      .status(500)
      .json({ status: false, error: 'Error inserting user' + msg });
  }
  const password_hash = await hash(req.body.password, 10);
  await db.query(`CALL insert_password(?,?)`, [uid, password_hash]);
  const { accessToken, hashed_token, iat } = await jwtGenerator(
    2,
    req.body.email
  );

  const expiry = new Date((iat + Number(process.env.JWT_EXPIRY)) * 1000);

  await db.query(`CALL insert_user_session(?, ?, ?, ?, ?, ?, ?, ?)`, [
    uid,
    hashed_token,
    Number(req.headers.device_type),
    req.headers.ip,
    req.headers.user_agent,
    expiry,
    req.body.gcmid,
    req.body.apnsid,
  ]);
  const [
    [
      [
        {
          full_name,
          email,
          phone,
          country_code,
          profile_picture_url,
          company_name,
          job_title,
          website,
          language_code,
          work_phone,
          work_country_code,
        },
      ],
    ],
  ] = await db.query(`CALL get_company_user_details(?)`, [uid]);
  await sendMail({
    to: req.body.email,
    subject: 'Welcome to Prepert',
    text: `Hello ${req.body.full_name},\n\nThank you for signing up on Prepert! We're excited to have you on board.\n\nBest regards,\nThe Prepert Team`,
  });

  res.status(201).json({
    status: true,
    message: 'User registered successfully',
    data: {
      user: {
        user_type: 2,
        full_name,
        email,
        phone,
        country_code,
        profile_picture_url,
        company_name,
        job_title,
        website,
        language_code,
        work_phone,
        work_country_code,
        token: accessToken,
      },
    },
  });
}

// Company user login
export async function companyLogin(req, res) {
  const [[[{ tid: uid }]]] = await db.query('CALL get_user(?)', [
    req.body.email,
  ]);
  if (!uid) {
    return res.status(404).json({
      status: false,
      error: 'User not found',
    });
  }
  const [[[{ password_hash: password }]]] = await db.query(
    `CALL get_password(?)`,
    [uid]
  );
  if (await compare(req.body.password, password)) {
    const { accessToken, hashed_token, iat } = await jwtGenerator(
      2,
      req.body.email
    );
    const expiry = new Date(iat + Number(process.env.JWT_EXPIRY) * 1000);
    await db.query('CALL insert_user_session(?, ?, ?, ?, ?, ?, ?, ?)', [
      uid,
      hashed_token,
      Number(req.headers.device_type),
      req.headers.ip,
      req.headers.user_agent,
      expiry,
      req.body.gcmid,
      req.body.apnsid,
    ]);
    const [
      [
        [
          {
            full_name,
            email,
            phone,
            country_code,
            profile_picture_url,
            company_name,
            job_title,
            website,
            language_code,
            work_phone,
            work_country_code,
          },
        ],
      ],
    ] = await db.query(`CALL get_company_user_details(?)`, [uid]);
    res.status(200).json({
      status: true,
      message: 'User logged in successfully',
      data: {
        user: {
          user_type: 2,
          full_name,
          email,
          phone,
          country_code,
          profile_picture_url,
          company_name,
          job_title,
          website,
          language_code,
          work_phone,
          work_country_code,
          token: accessToken,
        },
      },
    });
  } else {
    res.status(401).json({ status: false, error: 'Invalid email or password' });
  }
}

// Update company user profile
export async function updateProfileCompany(req, res) {
  const [[[{ tid: uid }]]] = await db.query(`CALL get_user(?)`, [
    req.user.email,
  ]);

  await db.query(`CALL update_user_company(?,?,?,?,?,?,?,?,?,?,?)`, [
    uid,
    req.body.full_name,
    req.body.phone,
    req.body.country_code,
    req.body.profile_picture_url,
    req.body.company_name,
    req.body.job_title,
    req.body.website,
    req.body.language_code,
    req.body.work_phone,
    req.body.work_country_code,
  ]);

  const [
    [
      [
        {
          full_name,
          email,
          phone,
          country_code,
          profile_picture_url,
          company_name,
          job_title,
          website,
          language_code,
          work_phone,
          work_country_code,
        },
      ],
    ],
  ] = await db.query(`CALL get_company_user_details(?)`, [uid]);

  res.status(200).json({
    status: true,
    message: 'Profile updated successfully',
    data: {
      user: {
        full_name,
        phone,
        country_code,
        profile_picture_url,
        company_name,
        job_title,
        website,
        language_code,
        work_phone,
        work_country_code,
      },
    },
  });
}

// Send OTP for change password request
export async function sendOtp(req, res) {
  // verify if user exists
  const [[[result]]] = await db.query(`CALL get_user(?)`, [req.user.email]);
  if (result.length > 0) {
    return res
      .status(409)
      .json({ status: false, error: 'User already exists' });
  }

  const otp = await otpGenerator(req.user.email);

  await sendMail({
    to: req.user.email,
    subject: 'Your OTP Code',
    text: `Your OTP code is ${otp}`,
  });

  res.status(200).json({ status: true, message: 'OTP sent to email' });
}

// verify the otp for change password request
export async function verifyOtp(req, res) {
  if (otpVerifier(req.body.otp, req.user.email)) {
    return res
      .status(200)
      .json({ status: true, message: 'OTP verified successfully' });
  } else {
    return res.status(400).json({
      status: false,
      error: 'Invalid OTP',
    });
  }
}

// Send OTP for change password request
export async function sendOtpEmail(req, res) {
  const otp = await otpGenerator(req.body.email);

  await sendMail({
    to: req.body.email,
    subject: 'Your OTP Code',
    text: `Your OTP code is ${otp}`,
  });

  res.status(200).json({ status: true, message: 'OTP sent to email' });
}

// verify the otp for change password request
export async function verifyOtpEmail(req, res) {
  if (otpVerifier(req.body.otp, req.body.email)) {
    return res
      .status(200)
      .json({ status: true, message: 'OTP verified successfully' });
  } else {
    return res.status(400).json({
      status: false,
      error: 'Invalid OTP',
    });
  }
}

// Change password for company user
export async function changePassword(req, res) {
  const [[[{ tid: uid }]]] = await db.query(`CALL get_user(?)`, [
    req.user.email,
  ]);
  const [[result]] = await db.query(`CALL get_previous_passwords(?)`, [uid]);
  for (const row of result) {
    if (await compare(req.body.password, row.password_hash)) {
      return res
        .status(409)
        .json({ status: false, error: 'Password already used' });
    }
  }
  const [[[{ password_hash: current_password }]]] = await db.query(
    `CALL get_password(?)`,
    [uid]
  );
  if (await compare(req.body.password, current_password)) {
    return res.status(409).json({
      status: false,
      error: 'New password cannot be same as current password',
    });
  }
  const password_hash = await hash(req.body.password, 10);
  await db.query(`CALL update_password(?,?)`, [uid, password_hash]);
  res.status(200).json({
    status: true,
    message: 'Password changed successfully',
  });
}

// function for forgot password
export async function forgotPassword(req, res) {
  const [[[{ tid: uid }]]] = await db.query(`CALL get_user(?)`, [
    req.body.email,
  ]);
  if (!uid) {
    return res.status(404).json({
      status: false,
      error: 'User not found',
    });
  }
  const [[result]] = await db.query(`CALL get_previous_passwords(?)`, [uid]);
  for (const row of result) {
    if (await compare(req.body.password, row.password_hash)) {
      return res
        .status(409)
        .json({ status: false, error: 'Password already used' });
    }
  }
  const [[[{ password_hash: current_password }]]] = await db.query(
    `CALL get_password(?)`,
    [uid]
  );
  if (await compare(req.body.password, current_password)) {
    return res.status(409).json({
      status: false,
      error: 'New password cannot be same as current password',
    });
  }
  const password_hash = await hash(req.body.password, 10);
  await db.query(`CALL update_password(?,?)`, [uid, password_hash]);
  res.status(200).json({
    status: true,
    message: 'Password reset request sent successfully',
  });
}

// function for logout
export async function logout(req, res) {
  const hashed_token = createHash('sha256')
    .update(req.headers.token)
    .digest('hex');

  await db.query(`CALL user_logout(?)`, [hashed_token]);

  res.status(200).json({
    status: true,
    message: 'User logged out successfully',
  });
}


import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import cookieParser from 'cookie-parser';

import router from './routes/userRoutes.js';

dotenv.config();

const app = express();
const port = process.env.SERVER_PORT || 3000;

// app.use(
//   cors({
//     origin: 'http://localhost:4200',
//     credentials: true,
//   })
// );

app.use(express.json());
app.use(cookieParser());

app.use(router);

app.listen(port, () => console.log(`Server is running on port ${port}`));