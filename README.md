# Pub GUI

A cross-platform desktop GUI for managing Flutter/Dart package dependencies. Search pub.dev, view installed packages, and add or remove dependencies without touching the terminal.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

## Features

- **Search packages** — live search against the pub.dev API with debounced input
- **Installed dependencies** — shows all dependencies from the selected project's `pubspec.yaml` when idle
- **Add & remove** — runs `flutter pub add` / `flutter pub remove` in your project directory
- **Parallel fetching** — package details are fetched concurrently for fast results
- **SDK auto-detection** — scans common install paths and `$PATH` on startup; falls back to manual selection
- **VS Code-inspired UI** — dark-first, sidebar + main panel layout

## Screenshots

*Coming soon*

## Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10 or later)
- A desktop environment (Windows, macOS, or Linux)

### Build from Source

```bash
git clone https://github.com/ardakoksal/pub_gui.git
cd pub_gui
flutter pub get
flutter run -d linux    # or macos / windows
```

### Build Release

```bash
flutter build linux    # or macos / windows
```

## Usage

1. Launch the app — it will detect your Flutter SDK automatically
2. Click **Open project folder** in the sidebar and select a folder containing `pubspec.yaml`
3. The main panel shows your current dependencies immediately
4. Type in the search bar to find packages on pub.dev
5. Click **Add** to install a package, or **Remove** to uninstall one

## Dependencies

| Package | Purpose |
|---|---|
| [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | State management |
| [http](https://pub.dev/packages/http) | pub.dev API calls |
| [file_selector](https://pub.dev/packages/file_selector) | Native folder/file picker |
| [url_launcher](https://pub.dev/packages/url_launcher) | Open package pages in browser |
| [process_run](https://pub.dev/packages/process_run) | Run `flutter pub` subprocesses |

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Author

**Arda Koksal**

---

Made with ❤️, Flutter, and [Claude Code](https://claude.ai/code) (mostly)
