import pool from "../config/database.js";

class ChatMessageModel {
  /**
   * Create a new chat message.
   */
  static async create({
    userId,
    role,
    content,
    conversationId = null,
    recipeId = null,
  }) {
    const query = `
      INSERT INTO chat_messages (user_id, role, content, conversation_id, recipe_id)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, role, content, created_at, conversation_id, recipe_id
    `;
    const result = await pool.query(query, [
      userId,
      role,
      content,
      conversationId,
      recipeId,
    ]);
    return result.rows[0];
  }

  /**
   * Retrieve conversation history for a user, paginated.
   * Includes full recipe data if recipe_id is present.
   */
  static async findByUserId(userId, limit = 50, offset = 0) {
    const query = `
      SELECT
        cm.id,
        cm.role,
        cm.content,
        cm.created_at,
        cm.recipe_id,
        cm.conversation_id,
        r.id as recipe_id,
        r.name as recipe_name,
        r.ingredients as recipe_ingredients,
        r.instructions as recipe_instructions,
        r.nutrition as recipe_nutrition,
        r.prep_time_minutes,
        r.cook_time_minutes,
        r.dietary_tags,
        r.allergen_warnings,
        r.image_url as recipe_image_url,
        r.created_at as recipe_created_at
      FROM chat_messages cm
      LEFT JOIN recipes r ON cm.recipe_id = r.id
      WHERE cm.user_id = $1
      ORDER BY cm.created_at DESC
      LIMIT $2 OFFSET $3
    `;
    const result = await pool.query(query, [userId, limit, offset]);

    // Transform rows to include recipe object if present
    const messages = result.rows.map((row) => {
      const message = {
        id: row.id,
        role: row.role,
        content: row.content,
        created_at: row.created_at,
        conversation_id: row.conversation_id,
      };

      // If recipe data exists, add it as a nested object
      if (row.recipe_id) {
        message.recipe = {
          id: row.recipe_id,
          name: row.recipe_name,
          ingredients: row.recipe_ingredients,
          instructions: row.recipe_instructions,
          nutrition: row.recipe_nutrition,
          prep_time_minutes: row.prep_time_minutes,
          cook_time_minutes: row.cook_time_minutes,
          dietary_tags: row.dietary_tags,
          allergen_warnings: row.allergen_warnings,
          image_url: row.recipe_image_url,
          created_at: row.recipe_created_at,
        };
      }

      return message;
    });

    // Return reverse order (oldest first) so client receives chronological history
    return messages.reverse();
  }

  /**
   * Retrieve messages for a specific conversation thread.
   */
  static async findByConversationId(conversationId) {
    const query = `
      SELECT * FROM chat_messages
      WHERE conversation_id = $1
      ORDER BY created_at ASC
    `;
    const result = await pool.query(query, [conversationId]);
    return result.rows;
  }
}

export default ChatMessageModel;
