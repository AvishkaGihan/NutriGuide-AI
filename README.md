# NutriGuide AI 🥑🤖

**Mobile-First AI Nutrition Assistant**

NutriGuide AI is a cross-platform mobile application that transforms meal planning using Generative AI. It features a conversational nutrition assistant and a "Fridge Scan" feature that uses computer vision to generate recipes based on ingredients you already have.

## 🚀 Features

- **Conversational AI Chat:** Ask for recipes, nutritional advice, or meal plans in natural language.
- **Fridge Photo Scanning:** Snap a photo of your ingredients to get instant, cookable recipe suggestions.
- **Personalized Nutrition:** Recipes adapt to your goals (e.g., Muscle Gain) and restrictions (e.g., Vegan, Nut-Free).
- **Smart Recipe Cards:** Detailed instructions with automatic macro (Protein/Carb/Fat) calculations.
- **Secure & Private:** Healthcare-compliant architecture with secure data handling.

## 🏗️ Architecture

- **Frontend:** [Flutter](./nutriguide/README.md) (Mobile - iOS/Android)
  - State Management: Riverpod
  - Local Storage: Hive
- **Backend:** [Node.js](./backend/README.md) (Express)
  - AI Engine: Google Gemini 1.5 Pro & Flash (Multimodal)
  - Database: PostgreSQL (User Data, Recipes)
  - Cache: Redis (Session, Rate Limiting)
- **DevOps:** Docker (Database containerization)

## 🛠️ Prerequisites

- [Node.js](https://nodejs.org/) (v20 LTS or higher)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.24 or higher)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Google Gemini API Key](https://aistudio.google.com/)

## ⚡ Quick Start

### 1. Setup Database

Start PostgreSQL and Redis using Docker:

````bash
docker-compose up -d
### 2. Setup Backend
Navigate to the backend directory, install dependencies, and start the server:

```bash
cd backend
npm install
# Create .env file (see [backend/README.md](./backend/README.md) for details)
npm run dev
````

Server will run on http://localhost:3000

### 3. Setup Frontend (Mobile App)

Open a new terminal, navigate to the mobile app directory:

```bash
cd nutriguide
flutter pub get
# Create assets/.env file (see [backend/README.md](./backend/README.md) configuration)
flutter run
```

## 🔐 Environment Configuration

### Backend (backend/.env):

```properties
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/nutriguide
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_secure_secret
GEMINI_API_KEY=your_google_api_key
```

### Frontend (nutriguide/assets/.env):

```properties
# Use 10.0.2.2 for Android Emulator to reach localhost
API_BASE_URL=http://10.0.2.2:3000/api/v1
```

## 🧪 Testing

- Backend: `cd backend && npm test` (see [Backend Documentation](./backend/README.md))
- Mobile: `cd nutriguide && flutter test` (see [Flutter App Documentation](./nutriguide/README.md))

## 📄 License

This project is licensed under the [ISC License](./LICENSE).
