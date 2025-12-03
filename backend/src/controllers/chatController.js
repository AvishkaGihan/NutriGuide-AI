import ChatMessageModel from "../models/ChatMessage.js";
import UserModel from "../models/User.js";
import GeminiService from "../services/geminiService.js";
import RecipeModel from "../models/Recipe.js";
import { asyncHandler } from "../utils/errorHandler.js";
import { logger } from "../services/loggerService.js";

/**
 * Send a message and stream the response (SSE)
 * POST /api/v1/chat/stream
 *
 * We use Server-Sent Events (SSE) instead of WebSockets to show a typing effect
 * in the UI, making the response feel more natural and interactive while keeping
 * the backend simpler (no persistent connections needed).
 */
export const streamMessage = asyncHandler(async (req, res) => {
  const { message, conversationId } = req.body;
  const userId = req.user.id;

  // 1. Setup SSE Headers
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");

  try {
    // 2. Save User Message
    await ChatMessageModel.create({
      userId,
      role: "user",
      content: message,
      conversationId,
    });

    // 3. Fetch Context (User Profile & Recent History)
    const userProfile = await UserModel.getFullProfile(userId);
    // In a real app, you'd fetch previous messages to pass as context
    // const history = await ChatMessageModel.findByConversationId(conversationId);

    // 4. Generate AI Response using Gemini
    let aiResponseText = "";
    let recipeData = null;

    // Check if user is asking for a recipe
    const isRecipeRequest = /recipe|cook|dinner|lunch|breakfast/i.test(message);

    if (isRecipeRequest) {
      // Generate structured recipe with Gemini
      res.write(
        `event: status\ndata: ${JSON.stringify({
          text: "Generating recipe...",
        })}\n\n`
      );

      const recipe = await GeminiService.generateRecipe({
        userProfile,
        ingredients: null,
        promptType: message,
      });

      // Save Recipe to DB - normalize nutrition_estimates to nutrition
      const savedRecipe = await RecipeModel.create({
        ...recipe,
        nutrition: recipe.nutrition_estimates, // Map nutrition_estimates to nutrition
        user_id: userId,
      });

      // Include full recipe data for the frontend
      recipeData = {
        ...savedRecipe,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        nutrition: recipe.nutrition_estimates,
        prep_time_minutes: recipe.prep_time_minutes,
        cook_time_minutes: recipe.cook_time_minutes,
        dietary_tags: recipe.dietary_tags,
        allergen_warnings: recipe.allergen_warnings,
      };
      aiResponseText = `Here is a recipe for ${recipe.name}.`;
    } else {
      // General chat - use Gemini for all questions
      res.write(
        `event: status\ndata: ${JSON.stringify({
          text: "Thinking...",
        })}\n\n`
      );

      aiResponseText = await GeminiService.generateChatResponse({
        userProfile,
        message,
      });
    }

    // 5. Stream Response to Client
    // Simulate typing effect
    const words = aiResponseText.split(" ");
    for (const word of words) {
      res.write(`event: token\ndata: ${JSON.stringify({ text: word + " " })}\n\n`);
      await new Promise((r) => setTimeout(r, 50)); // Artificial delay for 'typing' feel
    }

    // 6. Save AI Response to DB
    const savedMessage = await ChatMessageModel.create({
      userId,
      role: "assistant",
      content: aiResponseText,
      conversationId,
      recipeId: recipeData ? recipeData.id : null,
    });

    // 7. Final Event with Data - Include the complete message to prevent duplicate from being replayed
    res.write(
      `event: complete\ndata: ${JSON.stringify({
        id: savedMessage.id,
        content: aiResponseText,
        conversationId,
        recipe: recipeData,
      })}\n\n`
    );

    res.end();
  } catch (error) {
    logger.error("Failed to stream chat response", error);
    res.write(
      `event: error\ndata: ${JSON.stringify({
        message: "Failed to process request",
      })}\n\n`
    );
    res.end();
  }
});

/**
 * Get Chat History
 * GET /api/v1/chat/history
 */
export const getHistory = asyncHandler(async (req, res) => {
  const history = await ChatMessageModel.findByUserId(req.user.id);

  res.status(200).json({
    success: true,
    data: history,
  });
});
