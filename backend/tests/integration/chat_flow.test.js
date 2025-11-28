import { jest } from "@jest/globals";
import request from "supertest";
import app from "../../../src/app.js";
import ChatMessageModel from "../../../src/models/ChatMessage.js";
import GeminiService from "../../../src/services/geminiService.js";
import UserModel from "../../../src/models/User.js";
import jwt from "jsonwebtoken";

// Mocks
jest.mock("../../../src/models/ChatMessage.js");
jest.mock("../../../src/services/geminiService.js");
jest.mock("../../../src/models/User.js");

describe("Chat Integration Flow", () => {
  let token;

  beforeAll(() => {
    // Generate a valid fake token for testing protected routes
    token = jwt.sign(
      { id: "user-123", email: "test@test.com" },
      process.env.JWT_SECRET || "test_secret"
    );
  });

  beforeEach(() => {
    jest.clearAllMocks();
    // Setup default mocks
    UserModel.getFullProfile.mockResolvedValue({ dietary_goals: [] });
    ChatMessageModel.create.mockResolvedValue({ id: "msg-1" });
  });

  describe("POST /api/v1/chat/messages/stream", () => {
    it("should initiate SSE connection", async () => {
      GeminiService.generateRecipe.mockResolvedValue({
        name: "Mock Recipe",
        ingredients: [],
      });

      // Supertest handling of streams is limited, but we can check headers
      const response = await request(app)
        .post("/api/v1/chat/messages/stream")
        .set("Authorization", `Bearer ${token}`)
        .send({
          message: "Suggest a dinner",
          conversationId: "conv-1",
        })
        .buffer(true) // Attempt to buffer response
        .parse((res, callback) => {
          // SSE keeps connection open, so we might need to handle this manually
          // or expect a timeout if we wait for end.
          // For this test, valid headers imply success.
          res.on("data", () => {});
          res.on("end", () => callback(null, ""));
        });

      // Expect SSE Headers
      expect(response.headers["content-type"]).toMatch(/text\/event-stream/);
      expect(response.headers["cache-control"]).toBe("no-cache");
      expect(response.headers["connection"]).toBe("keep-alive");
    });

    it("should return 401 without token", async () => {
      const response = await request(app)
        .post("/api/v1/chat/messages/stream")
        .send({ message: "Hello" });

      expect(response.statusCode).toBe(401);
    });
  });

  describe("GET /api/v1/chat/history", () => {
    it("should retrieve chat history", async () => {
      const mockHistory = [
        { id: "1", content: "Hello", role: "user" },
        { id: "2", content: "Hi there", role: "assistant" },
      ];
      ChatMessageModel.findByUserId.mockResolvedValue(mockHistory);

      const response = await request(app)
        .get("/api/v1/chat/history")
        .set("Authorization", `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body.data).toHaveLength(2);
      expect(ChatMessageModel.findByUserId).toHaveBeenCalledWith("user-123");
    });
  });
});
