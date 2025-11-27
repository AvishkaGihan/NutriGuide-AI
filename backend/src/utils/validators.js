import Joi from "joi";

// Regex for password complexity:
// Min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
const PASSWORD_REGEX =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

/**
 * Standard Joi Schemas for the application
 */
const schemas = {
  // Authentication Schemas
  register: Joi.object({
    email: Joi.string()
      .email()
      .required()
      .trim()
      .lowercase()
      .messages({ "string.email": "Please provide a valid email address" }),

    password: Joi.string().pattern(PASSWORD_REGEX).required().messages({
      "string.pattern.base":
        "Password must be 8+ chars with 1 uppercase, 1 number, and 1 special char",
    }),

    // Optional profile fields during registration
    dietary_goals: Joi.array().items(Joi.string()).optional(),
    restrictions: Joi.array().items(Joi.string()).optional(),
    allergies: Joi.array().items(Joi.string()).optional(),
  }),

  login: Joi.object({
    email: Joi.string().email().required().trim().lowercase(),
    password: Joi.string().required(),
  }),

  // Chat/Recipe Schemas
  chatMessage: Joi.object({
    message: Joi.string().required().trim().min(1).max(1000), // Limit length for safety
    conversation_id: Joi.string().uuid().optional(),
    context: Joi.object().optional(), // Allow passing client context if needed
  }),

  // Ingredient Sanitization (for Manual Entry or Correction)
  ingredientList: Joi.object({
    ingredients: Joi.array()
      .items(
        Joi.object({
          name: Joi.string()
            .trim()
            .required()
            .min(2)
            .max(100)
            // Strip HTML/Script tags basic mitigation (though Joi escapes by default usually)
            .replace(/<\/?[^>]+(>|$)/g, ""),
          quantity: Joi.alternatives()
            .try(Joi.string(), Joi.number())
            .optional(),
          unit: Joi.string().optional().allow(""),
        })
      )
      .required()
      .min(1),
  }),

  // Common UUID Validation (for params like /recipes/:id)
  uuidParam: Joi.object({
    id: Joi.string()
      .uuid()
      .required()
      .messages({ "string.guid": "Invalid ID format" }),
  }),
};

/**
 * Generic validator helper function.
 * Validates data against a schema and throws specific error if invalid.
 * @param {Object} schema - The Joi schema
 * @param {Object} data - The data to validate
 * @returns {Object} - The validated, sanitized data
 */
export const validate = (schema, data) => {
  const { error, value } = schema.validate(data, {
    abortEarly: false, // Return all errors, not just the first one
    stripUnknown: true, // Remove fields not defined in schema (Security)
  });

  if (error) {
    const message = error.details.map((detail) => detail.message).join(", ");
    throw new Error(`Validation Error: ${message}`);
  }

  return value;
};

// Export individual validation functions for cleaner Controller usage
export const validateRegister = (data) => validate(schemas.register, data);
export const validateLogin = (data) => validate(schemas.login, data);
export const validateChatMessage = (data) =>
  validate(schemas.chatMessage, data);
export const validateIngredients = (data) =>
  validate(schemas.ingredientList, data);
export const validateId = (data) => validate(schemas.uuidParam, data);

export default schemas;
