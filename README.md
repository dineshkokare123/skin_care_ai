# SkinCare AI

An AI-powered skincare application built with Flutter.

## Features

- **Skin Quiz**: Determine skin type and concerns.
- **AI Chat**: Powered by Google Gemini.
- **Personalized Routine**: AM/PM steps based on analysis.
- **Dynamic Content**: Blog posts and product recommendations.

## Setup

1. **Install Dependencies**

   ```bash
   flutter pub get
   ```

2. **Configure API Key**
   Open `lib/features/chat/chat_screen.dart` and replace `YOUR_GEMINI_API_KEY` with your actual Google Gemini API key.

3. **Run the App**

   ```bash
   flutter run
   ```

## Architecture (MVP)

The app uses a modular structure:

- `lib/core`: Theme, Routing, Configuration.
- `lib/features`: Distinct feature modules (Quiz, Chat, Home, Routine).
- `lib/shared`: Reusable widgets.

## Admin Panel (Configuration)

Currently, content is managed in `lib/features/admin/admin_mock.dart` to simulated a remote backend.
To enable "updates without redeploying", migrate the `AdminConfig` data structures to:

1. **Firebase Remote Config** (for simple text/prompts).
2. **Firestore** (for Blog Posts and Products).
3. **Admin Dashboard**: Build a simple React/Flutter Web app that writes to Firestore.
