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
   */
  static async findByUserId(userId, limit = 50, offset = 0) {
    const query = `
      SELECT id, role, content, created_at, recipe_id, conversation_id
      FROM chat_messages
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT $2 OFFSET $3
    `;
    const result = await pool.query(query, [userId, limit, offset]);
    // Return reverse order (oldest first) so client receives chronological history
    return result.rows.reverse();
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
