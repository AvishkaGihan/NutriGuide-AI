import { jest } from "@jest/globals";
import request from "supertest";
import jwt from "jsonwebtoken";

// 1. Mocks
const mockMsgCreate = jest.fn();
const mockMsgFind = jest.fn();
const mockGenerate = jest.fn();
const mockProfile = jest.fn();
const mockRecipeCreate = jest.fn(); // New mock for Recipe

// Mock ChatMessage
await jest.unstable_mockModule("../../src/models/ChatMessage.js", () => ({
  default: { create: mockMsgCreate, findByUserId: mockMsgFind },
}));

// Mock Gemini Service
await jest.unstable_mockModule("../../src/services/geminiService.js", () => ({
  default: { generateRecipe: mockGenerate },
}));

// Mock User Model
await jest.unstable_mockModule("../../src/models/User.js", () => ({
  default: { getFullProfile: mockProfile },
}));

// Mock Recipe Model (Fixes the UUID error)
await jest.unstable_mockModule("../../src/models/Recipe.js", () => ({
  default: { create: mockRecipeCreate },
}));

// 2. Import App
const app = (await import("../../src/app.js")).default;

describe("Chat Integration Flow", () => {
  let token;

  beforeAll(() => {
    // We use a valid fake token. 'user-123' is fine here because
    // we are now mocking the Database models that would usually reject it.
    token = jwt.sign(
      { id: "user-123", email: "test@test.com" },
      process.env.JWT_SECRET || "dev-secret-key-change-in-prod"
    );
  });

  beforeEach(() => {
    jest.clearAllMocks();
    mockProfile.mockResolvedValue({});
    mockMsgCreate.mockResolvedValue({ id: "msg-1" });
    // Mock recipe creation success
    mockRecipeCreate.mockResolvedValue({ id: "recipe-1", name: "Mock Recipe" });
  });

  describe("POST /api/v1/chat/messages/stream", () => {
    it("should initiate SSE connection", async () => {
      // Mock Gemini returning a recipe structure
      mockGenerate.mockResolvedValue({ name: "Recipe", ingredients: [] });

      const response = await request(app)
        .post("/api/v1/chat/messages/stream")
        .set("Authorization", `Bearer ${token}`)
        .send({ message: "Suggest a dinner" });

      // Check for SSE headers
      expect(response.headers["content-type"]).toMatch(/text\/event-stream/);
    });
  });
});
