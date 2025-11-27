import pool from "../config/database.js";

class RecipeModel {
  /**
   * Save a generated recipe.
   */
  static async create(recipeData) {
    const {
      user_id,
      name,
      ingredients, // Array of objects: [{name, quantity, unit}]
      instructions, // Array of strings
      nutrition, // Object: {calories, protein, etc.}
      prep_time_minutes,
      cook_time_minutes,
      dietary_tags, // Array of strings
      allergen_warnings, // Array of strings
      source = "gemini_generated",
    } = recipeData;

    const query = `
      INSERT INTO recipes (
        user_id, name, ingredients, instructions, nutrition,
        prep_time_minutes, cook_time_minutes, dietary_tags,
        allergen_warnings, source
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING id, name, created_at
    `;

    const values = [
      user_id,
      name,
      JSON.stringify(ingredients),
      JSON.stringify(instructions),
      JSON.stringify(nutrition),
      prep_time_minutes,
      cook_time_minutes,
      dietary_tags,
      allergen_warnings,
      source,
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  /**
   * Find a specific recipe by ID.
   */
  static async findById(id) {
    const result = await pool.query(`SELECT * FROM recipes WHERE id = $1`, [
      id,
    ]);
    return result.rows[0];
  }

  /**
   * Get recent recipes generated for a user.
   */
  static async findByUserId(userId, limit = 20) {
    const query = `
      SELECT id, name, nutrition, prep_time_minutes, dietary_tags, created_at
      FROM recipes
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2
    `;
    const result = await pool.query(query, [userId, limit]);
    return result.rows;
  }
}

export default RecipeModel;
