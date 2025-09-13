# AGENTS.md - Coding Agent Guidelines for Pavo Flutter

## Build/Test/Lint Commands
- **Run app**: `flutter run`
- **Run all tests**: `flutter test`
- **Run single test file**: `flutter test test/widget_test.dart`
- **Analyze/lint**: `flutter analyze` (uses flutter_lints package)
- **Format code**: `dart format lib/`
- **Code generation**: `dart run build_runner build --delete-conflicting-outputs`
- **Clean**: `flutter clean` then `flutter pub get`

## Code Style & Conventions
- **Imports**: Absolute imports using `package:pavo_flutter/`, group by Flutter > packages > project
- **Files**: snake_case naming (e.g., `sign_in_screen.dart`, `auth_provider.dart`)
- **Classes**: PascalCase for classes, suffix with type (Screen, Provider, Service, Repository)
- **State**: Use Riverpod with `@riverpod` annotation, generate with build_runner
- **Widgets**: Prefer `ConsumerStatefulWidget`/`ConsumerState` for Riverpod integration
- **Logging**: Use `LogMixin` for service classes, provides structured logging methods
- **Error handling**: Wrap API calls in try-catch, use ApiException from `core/api/api_exceptions.dart`
- **Colors**: NEVER use `withOpacity()`, use `.withValues()` instead to avoid precision loss
- **Environment**: All config values must come from .env file, no hardcoded values
- **Architecture**: Feature-based structure with `providers/`, `screens/`, `widgets/` subdirectories