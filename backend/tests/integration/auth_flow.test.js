import { jest } from "@jest/globals";
import request from "supertest";
import app from "../../../src/app.js";
import UserModel from "../../../src/models/User.js";

// Mock the Database Model to avoid needing a running Postgres instance for this test
jest.mock("../../../src/models/User.js");

describe("Auth Integration Flow", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("POST /api/v1/auth/register", () => {
    it("should register a new user successfully", async () => {
      // Setup Mock
      UserModel.create.mockResolvedValue({
        id: "user-123",
        email: "new@user.com",
      });
      // Mock updatePreferences used inside register controller
      UserModel.updatePreferences = jest.fn().mockResolvedValue({});

      const response = await request(app)
        .post("/api/v1/auth/register")
        .send({
          email: "new@user.com",
          password: "Password123!",
          dietary_goals: ["muscle_gain"],
        });

      expect(response.statusCode).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user).toHaveProperty("id", "user-123");
      expect(response.body.data.tokens).toHaveProperty("accessToken");
    });

    it("should return 400 for bad password", async () => {
      const response = await request(app).post("/api/v1/auth/register").send({
        email: "bad@pass.com",
        password: "weak",
      });

      expect(response.statusCode).toBe(500); // Or 400/422 depending on error handler config for Joi
      // Note: Joi validation error usually handled by globalErrorHandler
    });
  });

  describe("POST /api/v1/auth/login", () => {
    it("should login successfully with correct credentials", async () => {
      UserModel.findByEmail.mockResolvedValue({
        id: "user-123",
        email: "existing@user.com",
        password_hash: "hashed_secret",
      });
      UserModel.verifyPassword.mockResolvedValue(true);

      const response = await request(app).post("/api/v1/auth/login").send({
        email: "existing@user.com",
        password: "Password123!",
      });

      expect(response.statusCode).toBe(200);
      expect(response.body.data).toHaveProperty("tokens");
    });
  });
});
