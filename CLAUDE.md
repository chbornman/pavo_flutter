# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pavo Flutter is a multi-service dashboard application built with Flutter that integrates with self-hosted services like Immich (photos), Paperless-ngx (documents), and Jellyfin (media).

## Development Commands

### Core Commands
- **Run the app**: `flutter run`
- **Build for Android**: `flutter build apk` or `flutter build appbundle`
- **Build for iOS**: `flutter build ios`
- **Build for Web**: `flutter build web`
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format lib/`
- **Clean build**: `flutter clean`
- **Get dependencies**: `flutter pub get`
- **Generate code**: `dart run build_runner build` or `dart run build_runner watch`

### Testing
- **Run all tests**: `flutter test`
- **Run specific test file**: `flutter test test/widget_test.dart`
- **Run with coverage**: `flutter test --coverage`

## Architecture

### Directory Structure
The application follows a feature-based architecture with clean separation of concerns:

- **lib/core/** - Core functionality shared across features
  - `api/` - API client and exception handling
  - `cache/` - Cache management
  - `config/` - Environment configuration (loads from .env)
  - `logging/` - Comprehensive logging system with crash reporting
  - `theme/` - Application theming and colors
  - `models/` - Shared data models (e.g., pagination)

- **lib/features/** - Feature modules with independent functionality
  - Each feature has: `providers/`, `screens/`, `widgets/`
  - Special structure for photos feature includes clean architecture layers:
    - `data/` (models, repositories, services)
    - `domain/` (entities)
    - `presentation/` (UI components)

- **lib/router/** - Navigation using go_router with authentication guards
- **lib/shared/** - Shared components across features

### State Management
Uses Riverpod for state management with code generation support via riverpod_generator.

### Authentication
Clerk Flutter integration for authentication, configured in `lib/app.dart` with ClerkAuth wrapper.

### Service Integrations
The app connects to multiple self-hosted services (configured via .env):
- **Immich**: Photo management
- **Paperless-ngx**: Document management  
- **Jellyfin**: Media server (movies, TV shows, music, audiobooks)

### Key Technical Details
- **Minimum Dart SDK**: 3.0.0
- **Navigation**: go_router with shell routes for nested navigation
- **HTTP Client**: Dio for networking
- **Storage**: SharedPreferences and flutter_secure_storage
- **Media**: video_player and just_audio
- **UI**: Material Design with Google Fonts support
- **Logging**: Custom logging system with LogMixin and crash reporting

## Environment Setup
1. Copy `.env.example` to `.env`
2. Configure service URLs and API keys for Clerk, Immich, Paperless-ngx, and Jellyfin
3. Run `flutter pub get` to install dependencies

## Code Generation
This project uses build_runner for generating Riverpod providers. Run code generation when modifying providers annotated with `@riverpod`:
```bash
dart run build_runner build --delete-conflicting-outputs
```
- no placeholder values! everything should be in the .env
- 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss