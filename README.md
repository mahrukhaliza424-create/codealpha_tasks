# EduFlip Flashcard App 🚀

A modern, AI-powered Flashcard and Study application built with Flutter. EduFlip helps students learn efficiently through beautiful design, spaced-repetition logic, and cutting-edge Gemini AI integration.

## ✨ Key Features
- **AI-Powered Card Generation**: Upload a PDF or paste text, and let Gemini AI automatically generate Question/Answer flashcards for you.
- **AI Study Explanations**: Stuck on a hard concept? Ask the AI to explain the flashcard answer using a real-world analogy.
- **Customizable Decks**: Full CRUD (Create, Read, Update, Delete) support for Decks and individual Flashcards.
- **Offline Capable**: All decks and cards are saved securely to a local SQLite database (`sqflite`).
- **Authentication**: Local profile and session management via `shared_preferences`.
- **Premium Design**: Built using sleek glassmorphism, smooth animations, and a dynamic gradient theme.

## 🛠 Tech Stack
- **Framework**: Flutter / Dart
- **State Management**: Provider
- **Local Storage**: SQFlite, SharedPreferences
- **AI Integration**: Custom HTTP client connecting directly to Google Gemini APIs (`v1` & `v1beta`)
- **PDF Processing**: `syncfusion_flutter_pdf` and `file_picker`
- **Animations**: `flutter_animate`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable branch)
- A valid Google Gemini API Key. (Get one from [Google AI Studio](https://aistudio.google.com/))

### Installation
1. Clone this repository.
2. Run `flutter pub get` to fetch all dependencies.
3. Create a `.env` file in the root directory and add your API key:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```
4. Run the app using `flutter run`.

## 🎨 UI Overview
- **Splash & Auth**: Animated welcome screen leading to a secure Login/Register flow.
- **Dashboard**: Your study hub. View deck progress, access the Navigation Drawer (Profile/Settings), and quickly generate decks manually or via PDF upload.
- **Study Mode**: An immersive, gesture-based 3D flashcard flipper. Swipe right if you've mastered it, left if you need to review it again!

---
*Built with ❤️ for modern learners.*
