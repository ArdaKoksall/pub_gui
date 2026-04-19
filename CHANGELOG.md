# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-19

Complete rewrite.

### Added
- Installed dependencies panel — shows all `dependencies:` from the selected project's `pubspec.yaml` on project open
- Remove packages via `flutter pub remove` with inline loading state
- Riverpod 3 state management replacing plain `setState`
- VS Code-inspired layout: sidebar (project selector + search) + main results panel
- Parallel pub.dev API calls for package detail fetching (~10x faster search)
- SDK path shown at the bottom of the sidebar when detected

### Changed
- Entire codebase split from a single 988-line `main.dart` into a layered structure (`models/`, `services/`, `providers/`, `screens/`, `widgets/`)
- UI redesigned with a dark-first VS Code aesthetic (`#1E1E1E` surface, `#9CDCFE` package names, `#4EC9B0` accents)
- Main panel now shows installed packages when idle and switches to search results while searching
- Theme defaults to dark mode

### Removed
- Single-file architecture
- Gradient avatar icons on package cards
- `process_run` dependency (replaced with `dart:io` `Process.run` directly)

## [0.0.1] - 2026-01-24

### Added
- Initial release
- Search packages from pub.dev API
- Add packages to Flutter projects with one click
- Automatic Flutter SDK detection and manual fallback
- Light and dark theme support
- Material Design 3 interface
- Cross-platform support (Windows, macOS, Linux)
- Debounced search
