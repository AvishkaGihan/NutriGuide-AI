# NutriGuide AI - Flutter App

The mobile frontend for NutriGuide AI, built with Flutter. This cross-platform app provides a conversational AI nutrition assistant and fridge scanning features using computer vision.

## 📁 Directory Structure

- `lib/` - Main application code
  - `app/` - App-level configurations and routing
  - `core/` - Core utilities, constants, and shared components
  - `features/` - Feature-specific modules (auth, chat, recipes, etc.)
- `assets/` - Static assets (images, fonts, config files)
- `test/` - Unit and widget tests
- `integration_test/` - Integration tests

## 🚀 Setup & Run

1. **Install Dependencies:**

   ```bash
   flutter pub get
   ```

2. **Environment Setup:**
   Create `assets/.env` file with your API configuration:

   ```bash
   # Use 10.0.2.2 for Android Emulator to reach localhost
   API_BASE_URL=http://10.0.2.2:3000/api/v1
   ```

3. **Run the App:**

   ```bash
   flutter run
   ```

   For specific platforms:

   ```bash
   flutter run -d android  # Android
   flutter run -d ios      # iOS
   flutter run -d chrome   # Web
   ```

## 🧪 Testing

Run unit and widget tests:

```bash
flutter test
```

Run integration tests:

```bash
flutter test integration_test/
```

## 📱 Features

- **AI Chat Interface:** Natural language conversation with nutrition AI
- **Fridge Scan:** Photo upload and ingredient detection
- **Recipe Generation:** AI-powered recipe suggestions
- **User Authentication:** Secure login and profile management
- **Offline Support:** Local data storage with Hive

## 🔧 Development

- **State Management:** Riverpod for reactive state
- **Local Storage:** Hive for persistent data
- **Networking:** HTTP client for API communication
- **Image Handling:** Camera and gallery access for photo features

## 📋 Prerequisites

- Flutter SDK (v3.24 or higher)
- Android Studio / Xcode for platform-specific development
- Backend API running (see [Root README](../README.md))
