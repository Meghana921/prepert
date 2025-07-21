import mysql from "mysql2/promise";
import dotenv from "dotenv";
dotenv.config();

const pool = mysql.createPool({
  host: process.env.HOST_NAME ,
  user: process.env.USER_NAME ,
  password: process.env.PASSWORD ,
  database: process.env.DB_NAME ,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

const testConnection = async () => {
  let connection;
  try {
    connection = await pool.getConnection();
    console.log("Successfully connected to database ");
  } catch (err) {
    console.error("Error connecting to the database:", err);
  } finally {
    if (connection) connection.release();
  }
};

export { pool , testConnection};
