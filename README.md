# Pub GUI

A beautiful, cross-platform graphical user interface for managing Flutter/Dart package dependencies. Search, browse, and add packages from [pub.dev](https://pub.dev) with ease.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

## Features

- 🔍 **Search Packages** - Search pub.dev packages directly from the app
- 📦 **Add Dependencies** - Add packages to your Flutter project with one click
- 🎨 **Modern UI** - Clean Material Design 3 interface with light/dark theme support
- 🖥️ **Cross-Platform** - Works on Windows, macOS, and Linux
- ⚡ **Auto-Detection** - Automatically detects Flutter SDK location
- 📋 **Package Details** - View package descriptions, versions, and homepage links

## Screenshots

*Coming soon*

## Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10 or later)
- A desktop environment (Windows, macOS, or Linux)

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/pub_gui.git
   cd pub_gui
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -d linux   # For Linux
   flutter run -d macos   # For macOS
   flutter run -d windows # For Windows
   ```

### Build Release

```bash
flutter build linux   # For Linux
flutter build macos   # For macOS
flutter build windows # For Windows
```

## Usage

1. **Open the app** and it will automatically detect your Flutter SDK
2. **Select a Flutter project** folder containing a `pubspec.yaml` file
3. **Search for packages** using the search bar
4. **Click "Add"** to add a package to your project's dependencies

## Dependencies

- [http](https://pub.dev/packages/http) - HTTP client for pub.dev API
- [file_selector](https://pub.dev/packages/file_selector) - Native file/folder selection
- [url_launcher](https://pub.dev/packages/url_launcher) - Open URLs in browser
- [process_run](https://pub.dev/packages/process_run) - Process execution utilities

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [pub.dev](https://pub.dev) for the package API
- [Flutter](https://flutter.dev) team for the amazing framework

## Author

**Arda Koksal**

---

Made with ❤️ and Flutter
