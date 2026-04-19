# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get       # Install dependencies
flutter run -d linux  # Run on Linux (also: macos, windows)
flutter analyze       # Lint and static analysis
flutter test          # Run tests (none exist yet)
flutter build linux   # Build release (also: macos, windows)
```

## Architecture

**pub_gui** is a cross-platform Flutter desktop app (Linux/macOS/Windows) that provides a GUI for managing Flutter/Dart package dependencies via pub.dev.

### All logic lives in a single file: `lib/main.dart` (~988 lines)

There is no component decomposition — one `DependencyManager` stateful widget handles everything using plain `setState`. No external state management library.

### Data flow

1. User picks a Flutter project folder → validates `pubspec.yaml` exists
2. Search input (debounced 500ms) → hits pub.dev REST API (`/api/search?q=<query>`, top 10 results)
3. Each result fetched individually from `/api/packages/<name>` for version/description details
4. "Add" button runs `flutter pub add <package>` via `process_run` in the selected project directory

### Flutter SDK auto-detection

On startup, checks platform-specific common paths, then `PATH`, then prompts manual selection via `file_selector`. SDK path stored in state; a status chip in the header shows detection result.

### Key dependencies

| Package | Purpose |
|---|---|
| `http` | pub.dev API calls |
| `file_selector` | Native folder/file picker |
| `url_launcher` | Open package pages in browser |
| `process_run` | Execute `flutter pub add` subprocess |

### UI

Material Design 3 with system light/dark theme. Single screen with: SDK status chip, project selector card, debounced search bar, and a `ListView` of package cards. Feedback via `SnackBar` (success) and `AlertDialog` (errors).
