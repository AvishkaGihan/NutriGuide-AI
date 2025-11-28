import { getChatModel, getVisionModel } from "../config/gemini.js";
import { AppError } from "../utils/errorHandler.js";

class GeminiService {
  /**
   * Generate a recipe based on chat context or ingredients.
   * Enforces JSON output for consistent app rendering.
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
      Response MUST be valid JSON with this structure:
      {
        "name": "Recipe Name",
        "description": "Brief appetizing description",
        "ingredients": [{"name": "item", "quantity": "amount", "unit": "unit"}],
        "instructions": ["Step 1", "Step 2"],
        "nutrition_estimates": {"calories": 0, "protein_g": 0, "carbs_g": 0, "fat_g": 0},
        "prep_time_minutes": 0,
        "cook_time_minutes": 0,
        "dietary_tags": ["High Protein", "Vegan", etc]
      }
      IMPORTANT: Ensure recipe strictly follows user allergies/restrictions.
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

      return JSON.parse(cleanJson);
    } catch (error) {
      console.error("Gemini Recipe Generation Error:", error);
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
      console.error("Gemini Vision Error:", error);
      throw new AppError("Failed to recognize ingredients in photo.", 502);
    }
  }
}

export default GeminiService;
