import { jest } from "@jest/globals";
import request from "supertest";

// 1. Mock DB Model (ESM style)
const mockUserCreate = jest.fn();
const mockUserFind = jest.fn();
const mockVerify = jest.fn();
const mockUpdatePref = jest.fn();

// Note: Path is ../../ because we are in tests/integration
await jest.unstable_mockModule("../../src/models/User.js", () => ({
  default: {
    create: mockUserCreate,
    findByEmail: mockUserFind,
    verifyPassword: mockVerify,
    updatePreferences: mockUpdatePref,
    findById: jest.fn(),
  },
}));

// 2. Import App (Corrected Path: ../../src/app.js)
const app = (await import("../../src/app.js")).default;

describe("Auth Integration Flow", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("POST /api/v1/auth/register", () => {
    it("should register a new user successfully", async () => {
      mockUserCreate.mockResolvedValue({
        id: "user-123",
        email: "new@user.com",
      });
      mockUpdatePref.mockResolvedValue({});

      const response = await request(app)
        .post("/api/v1/auth/register")
        .send({
          email: "new@user.com",
          password: "Password123!",
          dietary_goals: ["muscle_gain"],
        });

      expect(response.statusCode).toBe(201);
      expect(response.body.success).toBe(true);
    });
  });

  describe("POST /api/v1/auth/login", () => {
    it("should login successfully", async () => {
      mockUserFind.mockResolvedValue({
        id: "user-123",
        email: "existing@user.com",
        password_hash: "hashed",
      });
      mockVerify.mockResolvedValue(true);

      const response = await request(app)
        .post("/api/v1/auth/login")
        .send({ email: "existing@user.com", password: "Password123!" });

      expect(response.statusCode).toBe(200);
    });
  });
});
