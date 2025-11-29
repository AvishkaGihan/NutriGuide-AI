import { jest } from "@jest/globals";

// 1. Define Mocks
const mockGenerateContent = jest.fn();
const mockModel = { generateContent: mockGenerateContent };
const mockGetChatModel = jest.fn(() => mockModel);
const mockGetVisionModel = jest.fn(() => mockModel);

// 2. Register Mocks (Must be before imports)
await jest.unstable_mockModule("../../../src/config/gemini.js", () => ({
  getChatModel: mockGetChatModel,
  getVisionModel: mockGetVisionModel,
}));

// 3. Import Modules (Dynamic import required after unstable_mockModule)
const { default: GeminiService } = await import(
  "../../../src/services/geminiService.js"
);
const { AppError } = await import("../../../src/utils/errorHandler.js");
const { getChatModel: _getChatModel, getVisionModel: _getVisionModel } =
  await import("../../../src/config/gemini.js");

describe("GeminiService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("generateRecipe", () => {
    const mockProfile = {
      dietary_goals: ["weight_loss"],
      allergies: ["peanuts"],
    };
    const mockIngredients = ["chicken", "broccoli"];

    it("should return parsed JSON recipe on success", async () => {
      const mockResponseText = JSON.stringify({
        name: "Test Recipe",
        ingredients: [],
        instructions: [],
      });

      mockGenerateContent.mockResolvedValue({
        response: { text: () => mockResponseText },
      });

      const result = await GeminiService.generateRecipe({
        userProfile: mockProfile,
        ingredients: mockIngredients,
      });

      expect(result).toHaveProperty("name", "Test Recipe");
      expect(mockGenerateContent).toHaveBeenCalled();
    });

    it("should throw AppError when API fails", async () => {
      mockGenerateContent.mockRejectedValue(new Error("API Error"));

      // Suppress console.error for cleaner test output
      const consoleSpy = jest
        .spyOn(console, "error")
        .mockImplementation(() => {});

      await expect(
        GeminiService.generateRecipe({ userProfile: mockProfile })
      ).rejects.toThrow(AppError);

      consoleSpy.mockRestore();
    });
  });

  describe("analyzeImage", () => {
    it("should parse ingredient list from image analysis", async () => {
      const mockIngredients = ["apple", "banana"];

      mockGenerateContent.mockResolvedValue({
        response: { text: () => JSON.stringify(mockIngredients) },
      });

      const buffer = Buffer.from("fake-image");
      const result = await GeminiService.analyzeImage(buffer, "image/jpeg");

      expect(result).toEqual(mockIngredients);
    });
  });
});
