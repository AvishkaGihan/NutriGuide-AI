import bcrypt from "bcryptjs";
import pool from "../config/database.js";

class UserModel {
  /**
   * Create a new user and their default preferences in a single transaction.
   * @param {Object} userData - { email, password }
   */
  static async create({ email, password }) {
    const client = await pool.connect();

    try {
      await client.query("BEGIN");

      // 1. Hash the password
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(password, salt);

      // 2. Insert User
      const userQuery = `
        INSERT INTO users (email, password_hash)
        VALUES ($1, $2)
        RETURNING id, email, created_at
      `;
      const userResult = await client.query(userQuery, [email, passwordHash]);
      const user = userResult.rows[0];

      // 3. Create empty User Preferences record
      const prefQuery = `
        INSERT INTO user_preferences (user_id) VALUES ($1)
      `;
      await client.query(prefQuery, [user.id]);

      await client.query("COMMIT");
      return user;
    } catch (error) {
      await client.query("ROLLBACK");
      // PostgreSQL error code 23505 is unique violation (duplicate email)
      if (error.code === "23505") {
        throw new Error("Email already exists");
      }
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Find a user by email (for login).
   */
  static async findByEmail(email) {
    const result = await pool.query(
      `SELECT * FROM users WHERE email = $1 AND deleted_at IS NULL`,
      [email]
    );
    return result.rows[0];
  }

  /**
   * Find a user by ID (for profile fetching).
   */
  static async findById(id) {
    const result = await pool.query(
      `SELECT id, email, created_at FROM users WHERE id = $1 AND deleted_at IS NULL`,
      [id]
    );
    return result.rows[0];
  }

  /**
   * Verify password validity.
   */
  static async verifyPassword(candidatePassword, userPasswordHash) {
    return await bcrypt.compare(candidatePassword, userPasswordHash);
  }

  /**
   * Soft delete a user account.
   */
  static async softDelete(id) {
    await pool.query(
      `UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = $1`,
      [id]
    );
  }

  /**
   * Get full profile including preferences.
   */
  static async getFullProfile(userId) {
    const query = `
      SELECT u.id, u.email,
             p.dietary_goals, p.restrictions, p.allergies,
             p.activity_level, p.age_range, p.gender
      FROM users u
      LEFT JOIN user_preferences p ON u.id = p.user_id
      WHERE u.id = $1 AND u.deleted_at IS NULL
    `;
    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }

  /**
   * Update user preferences.
   */
  static async updatePreferences(userId, preferences) {
    const {
      dietary_goals,
      restrictions,
      allergies,
      activity_level,
      age_range,
      gender,
    } = preferences;

    const query = `
      UPDATE user_preferences
      SET dietary_goals = COALESCE($2, dietary_goals),
          restrictions = COALESCE($3, restrictions),
          allergies = COALESCE($4, allergies),
          activity_level = COALESCE($5, activity_level),
          age_range = COALESCE($6, age_range),
          gender = COALESCE($7, gender),
          updated_at = CURRENT_TIMESTAMP
      WHERE user_id = $1
      RETURNING *
    `;

    const result = await pool.query(query, [
      userId,
      dietary_goals,
      restrictions,
      allergies,
      activity_level,
      age_range,
      gender,
    ]);
    return result.rows[0];
  }
}

export default UserModel;
