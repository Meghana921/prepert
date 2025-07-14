import mysql from "mysql2/promise";
import dotenv from "dotenv";
dotenv.config();

const pool = mysql.createPool({
  host: process.env.HOST_NAME || "localhost",
  user: process.env.USER_NAME || "root",
  password: process.env.PASSWORD || "mysql",
  database: process.env.DB_NAME || "n3",
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
