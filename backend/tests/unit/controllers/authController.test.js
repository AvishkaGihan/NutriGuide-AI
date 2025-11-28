import { jest } from "@jest/globals";
import httpMocks from "node-mocks-http";
import * as authController from "../../../src/controllers/authController.js";
import UserModel from "../../../src/models/User.js";
import JwtService from "../../../src/services/jwtService.js";

// Mock dependencies
jest.mock("../../../src/models/User.js");
jest.mock("../../../src/services/jwtService.js");

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
      UserModel.create.mockResolvedValue(mockUser);
      JwtService.generateAccessToken.mockReturnValue("access_token");
      JwtService.generateRefreshToken.mockReturnValue("refresh_token");

      await authController.register(req, res, next);

      expect(res.statusCode).toBe(201);
      expect(res._getJSONData().data.tokens.accessToken).toBe("access_token");
      expect(UserModel.create).toHaveBeenCalledWith({
        email: "test@test.com",
        password: "Password123!",
      });
    });

    it("should call next with error if validation fails", async () => {
      req.body = { email: "invalid-email", password: "123" };

      await authController.register(req, res, next);

      expect(next).toHaveBeenCalled(); // Validation error
      expect(UserModel.create).not.toHaveBeenCalled();
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
      UserModel.findByEmail.mockResolvedValue(mockUser);
      UserModel.verifyPassword.mockResolvedValue(true);

      await authController.login(req, res, next);

      expect(res.statusCode).toBe(200);
      expect(UserModel.verifyPassword).toHaveBeenCalled();
    });

    it("should fail if user not found", async () => {
      req.body = { email: "wrong@test.com", password: "Password123!" };
      UserModel.findByEmail.mockResolvedValue(null);

      await authController.login(req, res, next);

      expect(next).toHaveBeenCalled();
      expect(next.mock.calls[0][0].message).toMatch(
        /Invalid email or password/
      );
    });
  });
});
