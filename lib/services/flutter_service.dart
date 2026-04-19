import 'dart:io';

class FlutterService {
  Future<String?> detectSdk() async {
    final exec = Platform.isWindows ? 'flutter.bat' : 'flutter';
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE'] ?? 'C:\\'
        : Platform.environment['HOME'] ?? '/';

    final candidates = [
      '$home/flutter/bin/$exec',
      '$home/development/flutter/bin/$exec',
      '$home/snap/flutter/common/flutter/bin/$exec',
      '/usr/local/bin/$exec',
      if (Platform.isWindows) ...[
        '$home\\flutter\\bin\\$exec',
        'C:\\src\\flutter\\bin\\$exec',
        'C:\\flutter\\bin\\$exec',
      ],
    ];

    for (final path in candidates) {
      if (await File(path).exists()) return path;
    }

    return _checkPath(exec);
  }

  String? _checkPath(String exec) {
    final pathVar = Platform.environment['PATH'] ?? '';
    final sep = Platform.isWindows ? ';' : ':';
    for (final dir in pathVar.split(sep)) {
      final full = '$dir${Platform.pathSeparator}$exec';
      if (File(full).existsSync()) return full;
    }
    return null;
  }

  Future<void> addPackage({
    required String sdkPath,
    required String projectPath,
    required String packageName,
  }) async {
    final result = await Process.run(
      sdkPath,
      ['pub', 'add', packageName],
      workingDirectory: projectPath,
      runInShell: true,
    );
    if (result.exitCode != 0) throw Exception(result.stderr.toString());
  }

  Future<void> removePackage({
    required String sdkPath,
    required String projectPath,
    required String packageName,
  }) async {
    final result = await Process.run(
      sdkPath,
      ['pub', 'remove', packageName],
      workingDirectory: projectPath,
      runInShell: true,
    );
    if (result.exitCode != 0) throw Exception(result.stderr.toString());
  }
}
