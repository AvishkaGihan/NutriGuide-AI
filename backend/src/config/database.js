import pg from "pg";
import { config } from "./env.js";

const { Pool } = pg;

// Initialize the Connection Pool
const pool = new Pool({
  connectionString: config.db.url,
  max: 20, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 2000, // Return an error if connection takes > 2 seconds
});

// Event Listener: Successful connection
pool.on("connect", () => {
  // Use a debug logger here in real app, console.log used for simplicity in setup
  if (config.env === "development") {
    console.log("📦 Database connected successfully");
  }
});

// Event Listener: Unexpected error on idle client
pool.on("error", (err) => {
  console.error("❌ Unexpected error on idle database client", err);
  process.exit(-1); // Critical failure, restart process
});

/**
 * Helper function to query the database.
 * This is a wrapper around pool.query to make it easier to mock in tests
 * and add logging if needed.
 * * @param {string} text - The SQL query text
 * @param {Array} params - The query parameters
 * @returns {Promise} - The query result
 */
export const query = (text, params) => pool.query(text, params);

/**
 * Helper to check database health.
 * Used for /health endpoints.
 */
export const checkDatabaseHealth = async () => {
  try {
    const start = Date.now();
    await pool.query("SELECT 1");
    const duration = Date.now() - start;
    return { status: "healthy", duration: `${duration}ms` };
  } catch (error) {
    return { status: "unhealthy", error: error.message };
  }
};

// Export the raw pool for transactions if needed
export default pool;
