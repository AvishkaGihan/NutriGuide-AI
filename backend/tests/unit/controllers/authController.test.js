import { jest } from "@jest/globals";
import httpMocks from "node-mocks-http";

// 1. Define Mocks
const mockUserCreate = jest.fn();
const mockUserFind = jest.fn();
const mockVerifyPassword = jest.fn();
const mockGenerateAccess = jest.fn();
const mockGenerateRefresh = jest.fn();
const mockUpdatePreferences = jest.fn();

// 2. Register Mocks
await jest.unstable_mockModule("../../../src/models/User.js", () => ({
  default: {
    create: mockUserCreate,
    findByEmail: mockUserFind,
    verifyPassword: mockVerifyPassword,
    updatePreferences: mockUpdatePreferences,
  },
}));

await jest.unstable_mockModule("../../../src/services/jwtService.js", () => ({
  default: {
    generateAccessToken: mockGenerateAccess,
    generateRefreshToken: mockGenerateRefresh,
  },
}));

// 3. Import Controller
const authController = await import(
  "../../../src/controllers/authController.js"
);
const _UserModel = (await import("../../../src/models/User.js")).default;

describe("AuthController", () => {
  let req, res, next;

  beforeEach(() => {
    req = httpMocks.createRequest();
    res = httpMocks.createResponse();
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("register", () => {
    it("should create user and return tokens on valid input", async () => {
      req.body = { email: "test@test.com", password: "Password123!" };

      const mockUser = { id: "123", email: "test@test.com" };
      mockUserCreate.mockResolvedValue(mockUser);
      mockGenerateAccess.mockReturnValue("access_token");
      mockGenerateRefresh.mockReturnValue("refresh_token");

      await authController.register(req, res, next);

      expect(res.statusCode).toBe(201);
      expect(res._getJSONData().data.tokens.accessToken).toBe("access_token");
      expect(mockUserCreate).toHaveBeenCalled();
    });

    it("should call next with error if validation fails", async () => {
      req.body = { email: "invalid-email", password: "123" };
      await authController.register(req, res, next);
      expect(next).toHaveBeenCalled();
      expect(mockUserCreate).not.toHaveBeenCalled();
    });
  });

  describe("login", () => {
    it("should return tokens if credentials are valid", async () => {
      req.body = { email: "test@test.com", password: "Password123!" };

      const mockUser = {
        id: "123",
        email: "test@test.com",
        password_hash: "hashed",
      };
      mockUserFind.mockResolvedValue(mockUser);
      mockVerifyPassword.mockResolvedValue(true);
      mockGenerateAccess.mockReturnValue("access_token");

      await authController.login(req, res, next);

      expect(res.statusCode).toBe(200);
    });
  });
});
