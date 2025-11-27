import pool from "../config/database.js";

class PhotoModel {
  /**
   * Record a new photo scan.
   */
  static async create({ userId, s3Key, ingredientsDetected }) {
    const query = `
      INSERT INTO photos (user_id, s3_key, ingredients_detected)
      VALUES ($1, $2, $3)
      RETURNING id, created_at, ingredients_detected
    `;

    // ingredientsDetected is expected to be a JSON object or array
    const result = await pool.query(query, [
      userId,
      s3Key,
      JSON.stringify(ingredientsDetected),
    ]);
    return result.rows[0];
  }

  /**
   * Find photo by ID.
   */
  static async findById(id) {
    const result = await pool.query(
      `SELECT * FROM photos WHERE id = $1 AND deleted_at IS NULL`,
      [id]
    );
    return result.rows[0];
  }

  /**
   * Get user's recent scan history.
   */
  static async findByUserId(userId, limit = 10) {
    const query = `
      SELECT id, created_at, ingredients_detected
      FROM photos
      WHERE user_id = $1 AND deleted_at IS NULL
      ORDER BY created_at DESC
      LIMIT $2
    `;
    const result = await pool.query(query, [userId, limit]);
    return result.rows;
  }

  /**
   * Cleanup: Delete photos older than 90 days (Privacy requirement).
   * This would typically be run by a cron job.
   */
  static async deleteOldPhotos() {
    const query = `
      UPDATE photos
      SET deleted_at = CURRENT_TIMESTAMP
      WHERE created_at < NOW() - INTERVAL '90 days'
        AND deleted_at IS NULL
      RETURNING id, s3_key
    `;
    const result = await pool.query(query);
    return result.rows; // Returns list of IDs/Keys to clean up from Cloud Storage
  }
}

export default PhotoModel;
