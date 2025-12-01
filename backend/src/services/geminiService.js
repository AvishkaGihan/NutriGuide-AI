import { getChatModel, getVisionModel } from "../config/gemini.js";
import { AppError } from "../utils/errorHandler.js";

class GeminiService {
  /**
   * Generate a chat response for general nutrition/cooking questions.
   * Uses Gemini to provide conversational, helpful responses.
   */
  static async generateChatResponse({ userProfile, message }) {
    const model = getChatModel();

    const basePrompt = `
      You are NutriGuide, a helpful nutritionist and cooking assistant.
      User Profile:
      - Goals: ${userProfile.dietary_goals?.join(", ") || "General Wellness"}
      - Restrictions: ${userProfile.restrictions?.join(", ") || "None"}
      - Allergies: ${userProfile.allergies?.join(", ") || "None"}

      Answer the user's question helpfully and concisely (1-2 sentences max).
      Provide practical advice related to nutrition, recipes, ingredients, or healthy eating.
    `;

    try {
      const result = await model.generateContent(
        `${basePrompt}\n\nUser: ${message}`
      );
      const response = await result.response;
      const text = response.text();
      return text;
    } catch (error) {
      console.error("Gemini Chat Response Error:", error);
      throw new AppError("Failed to generate response. Please try again.", 502);
    }
  }

  /**
   * Generate a recipe based on chat context or ingredients.
   * Enforces JSON output for consistent app rendering.
   * Includes image search query that gets converted to a working URL.
   */
  static async generateRecipe({
    userProfile,
    ingredients,
    promptType = "suggest",
  }) {
    const model = getChatModel();

    // Construct the context-aware prompt
    const basePrompt = `
      You are NutriGuide, an expert nutritionist and chef.
      User Profile:
      - Goals: ${userProfile.dietary_goals?.join(", ") || "General Wellness"}
      - Restrictions: ${userProfile.restrictions?.join(", ") || "None"}
      - Allergies: ${userProfile.allergies?.join(", ") || "None"}
    `;

    const taskPrompt = ingredients
      ? `Create a recipe using these ingredients: ${ingredients.join(", ")}.`
      : `Suggest a recipe based on this request: "${promptType}"`;

    const formatPrompt = `
      Response MUST be valid JSON with this EXACT structure. Use real, realistic values:
      {
        "name": "Recipe Name",
        "description": "Brief appetizing description",
        "ingredients": [
          {"name": "chicken breast", "quantity": "200", "unit": "grams"},
          {"name": "broccoli", "quantity": "2", "unit": "cups"}
        ],
        "instructions": [
          "Preheat oven to 400F",
          "Season chicken with salt and pepper",
          "Bake for 20-25 minutes until cooked through"
        ],
        "nutrition_estimates": {
          "calories": 350,
          "protein_g": 45,
          "carbs_g": 15,
          "fat_g": 12
        },
        "prep_time_minutes": 15,
        "cook_time_minutes": 25,
        "dietary_tags": ["High Protein", "Gluten Free"],
        "image_keyword": "pizza"
      }

      CRITICAL REQUIREMENTS:
      - calories MUST be a realistic number between 200-1000 (NEVER 0)
      - protein_g, carbs_g, fat_g MUST be realistic positive numbers (NEVER 0)
      - prep_time_minutes and cook_time_minutes MUST be realistic positive integers (NEVER 0)
      - ingredients array MUST contain 5+ items with realistic quantities and units
      - instructions array MUST contain 5+ clear, numbered steps
      - dietary_tags MUST list relevant tags (Vegan, Gluten Free, High Protein, etc)
      - image_keyword MUST be ONE of these ONLY: pizza, burger, pasta, biryani, dessert, dosa, idly, rice, samosa, butter-chicken
      - Ensure recipe strictly follows user allergies/restrictions
    `;

    try {
      const result = await model.generateContent(
        `${basePrompt}\n${taskPrompt}\n${formatPrompt}`
      );
      const response = await result.response;
      const text = response.text();

      // Clean up markdown code blocks if Gemini includes them (e.g. ```json ... ```)
      const cleanJson = text
        .replace(/```json/g, "")
        .replace(/```/g, "")
        .trim();

      const recipe = JSON.parse(cleanJson);

      // Generate a food image URL using Foodish API with recipe-specific keyword
      // This provides actual food photos that match the recipe
      if (!recipe.image_url) {
        let imageKeyword = recipe.image_keyword || "food";
        // Clean up the keyword: remove spaces, convert to lowercase
        imageKeyword = imageKeyword.toLowerCase().replace(/\s+/g, "-");
        // Use the image_keyword to get relevant images
        recipe.image_url = `https://foodish-api.com/images/${imageKeyword}/${imageKeyword}${
          Math.floor(Math.random() * 10) + 1
        }.jpg`;
      }
      delete recipe.image_keyword; // Remove keyword after using it

      return recipe;
    } catch (error) {
      if (process.env.NODE_ENV === "development") {
        console.error("Gemini Recipe Generation Error:", error);
      }
      throw new AppError("Failed to generate recipe. Please try again.", 502);
    }
  }

  /**
   * Analyze a photo of a fridge/pantry.
   * @param {Buffer} imageBuffer - The image data
   * @param {String} mimeType - e.g., 'image/jpeg'
   */
  static async analyzeImage(imageBuffer, mimeType) {
    const model = getVisionModel();

    const prompt = `
      Analyze this image of food ingredients.
      List every edible ingredient you see.
      Return ONLY a JSON array of strings, e.g.: ["chicken breast", "broccoli", "eggs"].
      Do not include non-food items.
    `;

    try {
      const imagePart = {
        inlineData: {
          data: imageBuffer.toString("base64"),
          mimeType: mimeType,
        },
      };

      const result = await model.generateContent([prompt, imagePart]);
      const response = await result.response;
      const text = response.text();

      const cleanJson = text
        .replace(/```json/g, "")
        .replace(/```/g, "")
        .trim();
      return JSON.parse(cleanJson);
    } catch (error) {
      if (process.env.NODE_ENV === "development") {
        console.error("Gemini Vision Error:", error);
      }
      throw new AppError("Failed to recognize ingredients in photo.", 502);
    }
  }
}

export default GeminiService;
