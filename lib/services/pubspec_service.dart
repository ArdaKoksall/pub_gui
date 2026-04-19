import 'dart:io';

class InstalledPackage {
  final String name;
  final String version;

  const InstalledPackage({required this.name, required this.version});
}

class PubspecService {
  Future<List<InstalledPackage>> loadDependencies(String projectPath) async {
    final file = File('$projectPath/pubspec.yaml');
    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    final result = <InstalledPackage>[];
    bool inDeps = false;

    for (final line in lines) {
      if (line.trimRight() == 'dependencies:') {
        inDeps = true;
        continue;
      }
      if (inDeps) {
        // Stop at next top-level key
        if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) {
          break;
        }
        // Match exactly 2-space indented "  name: value" lines
        final match = RegExp(
          r'^  ([a-zA-Z][a-zA-Z0-9_]*): (.+)$',
        ).firstMatch(line);
        if (match != null) {
          final name = match.group(1)!;
          final version = match.group(2)!.trim();
          // Skip sdk entries like "sdk: flutter"
          if (!version.startsWith('sdk:') && version != 'flutter') {
            result.add(InstalledPackage(name: name, version: version));
          }
        }
      }
    }

    return result;
  }
}
