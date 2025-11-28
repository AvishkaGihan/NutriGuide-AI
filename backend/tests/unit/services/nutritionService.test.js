import NutritionService from "../../../src/services/nutritionService.js";

describe("NutritionService", () => {
  describe("calculateRecipeMacros", () => {
    it("should correctly sum up macros from ingredients", () => {
      const ingredients = [
        {
          name: "Chicken",
          nutrition: { calories: 100, protein: 20, carbs: 0, fat: 2 },
        },
        {
          name: "Rice",
          nutrition: { calories: 150, protein: 3, carbs: 30, fat: 0 },
        },
      ];

      const total = NutritionService.calculateRecipeMacros(ingredients);

      expect(total.calories).toBe(250);
      expect(total.protein).toBe(23);
      expect(total.carbs).toBe(30);
      expect(total.fat).toBe(2);
    });

    it("should handle missing nutrition data gracefully", () => {
      const ingredients = [
        { name: "Water", nutrition: null }, // No data
        { name: "Apple", nutrition: { calories: 50 } }, // Partial data
      ];

      const total = NutritionService.calculateRecipeMacros(ingredients);
      expect(total.calories).toBe(50);
      expect(total.protein).toBe(0);
    });
  });

  describe("checkAllergens", () => {
    const recipe = {
      ingredients: [
        { name: "Peanut Butter", quantity: "2 tbsp" },
        { name: "Bread", quantity: "2 slices" },
      ],
    };

    it("should detect allergens present in ingredients", () => {
      const warnings = NutritionService.checkAllergens(recipe, [
        "Peanut",
        "Shellfish",
      ]);
      expect(warnings).toHaveLength(1);
      expect(warnings[0]).toMatch(/Contains Peanut/);
    });

    it("should return empty list if no allergens matches", () => {
      const warnings = NutritionService.checkAllergens(recipe, [
        "Dairy",
        "Soy",
      ]);
      expect(warnings).toHaveLength(0);
    });

    it("should be case insensitive", () => {
      const warnings = NutritionService.checkAllergens(recipe, ["peanut"]);
      expect(warnings).toHaveLength(1);
    });
  });
});
