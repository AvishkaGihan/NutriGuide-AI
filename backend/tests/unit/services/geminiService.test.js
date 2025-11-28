import { jest } from "@jest/globals";
import GeminiService from "../../../src/services/geminiService.js";
import { AppError } from "../../../src/utils/errorHandler.js";

// Mock the config
jest.mock("../../../src/config/gemini.js", () => {
  return {
    getChatModel: jest.fn(),
    getVisionModel: jest.fn(),
  };
});

import { getChatModel, getVisionModel } from "../../../src/config/gemini.js";

describe("GeminiService", () => {
  let mockGenerateContent;

  beforeEach(() => {
    // Reset mocks before each test
    mockGenerateContent = jest.fn();
    getChatModel.mockReturnValue({ generateContent: mockGenerateContent });
    getVisionModel.mockReturnValue({ generateContent: mockGenerateContent });
  });

  describe("generateRecipe", () => {
    const mockProfile = {
      dietary_goals: ["weight_loss"],
      allergies: ["peanuts"],
    };
    const mockIngredients = ["chicken", "broccoli"];

    it("should return parsed JSON recipe on success", async () => {
      // Mock successful API response
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
      expect(mockGenerateContent).toHaveBeenCalledTimes(1);
      // Verify prompt contains user profile info
      expect(mockGenerateContent.mock.calls[0][0]).toContain("weight_loss");
      expect(mockGenerateContent.mock.calls[0][0]).toContain("peanuts");
    });

    it("should throw AppError when API fails", async () => {
      mockGenerateContent.mockRejectedValue(new Error("API Error"));

      await expect(
        GeminiService.generateRecipe({ userProfile: mockProfile })
      ).rejects.toThrow(AppError);
    });

    it("should clean up markdown code blocks from response", async () => {
      // Gemini often wraps JSON in ```json ... ```
      const markdownJson =
        "```json\n" + JSON.stringify({ name: "Cleaned" }) + "\n```";

      mockGenerateContent.mockResolvedValue({
        response: { text: () => markdownJson },
      });

      const result = await GeminiService.generateRecipe({
        userProfile: mockProfile,
      });
      expect(result).toHaveProperty("name", "Cleaned");
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
      expect(getVisionModel).toHaveBeenCalled();
    });
  });
});
