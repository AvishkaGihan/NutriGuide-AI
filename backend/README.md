# NutriGuide AI - Backend API

The backend service for NutriGuide AI, built with Node.js, Express, and PostgreSQL. It handles authentication, data persistence, and orchestration of Google Gemini AI services.

For project overview, see [Root README](../README.md).

## 📁 Directory Structure

- `src/config` - Database, Env, and AI configuration.
- `src/controllers` - Request handlers (logic).
- `src/models` - Data access layer (SQL queries).
- `src/routes` - API endpoint definitions.
- `src/services` - Business logic (AI, Auth, Nutrition).
- `src/middleware` - Auth checks, logging, error handling.

## 🚀 Setup & Run

1.  **Install Dependencies:**

    ```bash
    npm install
    ```

2.  **Environment Setup:**
    Copy `.env.example` to `.env` and fill in your keys:

    ```bash
    cp .env.example .env
    ```

3.  **Database Migration:**
    Ensure Docker is running (`docker-compose up -d` at root).
    The database schema is initialized automatically via the `init.sql` script mapped in `docker-compose.yml`.

    To reset the database manually:

    ```bash
    docker exec -it nutriguide_db psql -U user -d nutriguide -f /init.sql
    ```

4.  **Start Server:**
    ```bash
    npm run dev
    ```

## 📡 API Endpoints

**Base URL:** `/api/v1`

### Authentication

- `POST /auth/register` - Create account
- `POST /auth/login` - Login & get tokens
- `POST /auth/refresh-token` - Refresh access token

### Chat (AI)

- `POST /chat/messages/stream` - Send message & stream response (SSE)
- `GET /chat/history` - Get conversation history

### Photos

- `POST /photos/analyze` - Upload image (multipart) for ingredient detection

### Recipes

- `GET /recipes` - Get user's saved recipes
- `GET /recipes/:id` - Get recipe details
- `POST /recipes/:id/variation` - Request recipe modification (e.g. "Make Vegan")

### User

- `GET /user/profile` - Get dietary preferences
- `PUT /user/profile` - Update preferences
- `GET /user/export-data` - GDPR data export

## 🧪 Testing

Run unit and integration tests:

```bash
npm test
```
