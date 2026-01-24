# Contributing to Pub GUI

Thank you for your interest in contributing to Pub GUI! This document provides guidelines and information about contributing.

## Code of Conduct

Please be respectful and considerate in all interactions. We're all here to build something great together.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/ardakoksal/pub_gui/issues)
2. If not, create a new issue with:
   - A clear, descriptive title
   - Steps to reproduce the bug
   - Expected vs actual behavior
   - Your environment (OS, Flutter version, etc.)

### Suggesting Features

1. Check existing issues and discussions
2. Create a new issue with:
   - A clear description of the feature
   - Why it would be useful
   - Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Run tests and analysis:
   ```bash
   flutter analyze
   flutter test
   ```
5. Commit with clear, descriptive messages
6. Push to your fork
7. Open a Pull Request

## Development Setup

1. Ensure you have Flutter installed (3.10+)
2. Clone the repository:
   ```bash
   git clone https://github.com/ardakoksal/pub_gui.git
   cd pub_gui
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run -d linux  # or macos/windows
   ```

## Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing
- Use meaningful variable and function names
- Add comments for complex logic

## Questions?

Feel free to open an issue for any questions or discussions.
