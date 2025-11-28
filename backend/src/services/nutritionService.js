import axios from "axios";
import { AppError } from "../utils/errorHandler.js";

// Placeholder for USDA API URL
const USDA_API_URL = "https://api.nal.usda.gov/fdc/v1/foods/search";

class NutritionService {
  /**
   * Calculate macros for a list of ingredients.
   * (Simplified logic for MVP - in production, this aggregates real API data)
   */
  static calculateRecipeMacros(ingredients) {
    // Logic: Iterate through ingredients, fetch/estimate nutrition, sum them up.
    // For MVP generated recipes, Gemini usually provides the estimates directly.
    // This service serves as a validator or fallback.

    let total = {
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
    };

    // If ingredients have nutrition data attached (from Gemini or DB)
    ingredients.forEach((ing) => {
      if (ing.nutrition) {
        total.calories += ing.nutrition.calories || 0;
        total.protein += ing.nutrition.protein || 0;
        total.carbs += ing.nutrition.carbs || 0;
        total.fat += ing.nutrition.fat || 0;
      }
    });

    return total;
  }

  /**
   * Check if a recipe conflicts with user allergies.
   * Returns an array of detected warnings.
   */
  static checkAllergens(recipe, userAllergies = []) {
    if (!userAllergies || userAllergies.length === 0) return [];

    const warnings = [];
    // Convert recipe ingredients to a searchable string
    const recipeString = JSON.stringify(recipe.ingredients).toLowerCase();

    userAllergies.forEach((allergy) => {
      if (recipeString.includes(allergy.toLowerCase())) {
        warnings.push(`Contains ${allergy}`);
      }
    });

    return warnings;
  }

  /**
   * Fetch specific ingredient info from USDA (Optional/Future).
   * requires USDA_API_KEY in .env
   */
  static async fetchIngredientInfo(query) {
    if (!process.env.USDA_API_KEY) return null;

    try {
      const response = await axios.get(USDA_API_URL, {
        params: {
          api_key: process.env.USDA_API_KEY,
          query: query,
          pageSize: 1,
        },
      });
      return response.data.foods[0];
    } catch (_error) {
      console.error("USDA API Error:", _error);
      throw new AppError("Failed to fetch ingredient info from USDA API", 500);
    }
  }
}

export default NutritionService;
