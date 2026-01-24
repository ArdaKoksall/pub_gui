import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_selector/file_selector.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pubspec GUI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0175C2),
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0175C2), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0175C2),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Segoe UI',
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade800),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF54C5F8), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DependencyManager(),
    );
  }
}

class DependencyManager extends StatefulWidget {
  const DependencyManager({super.key});

  @override
  State<DependencyManager> createState() => _DependencyManagerState();
}

class _DependencyManagerState extends State<DependencyManager> {
  String? _projectPath;
  String? _flutterExecutablePath;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  final Set<String> _addingPackages = {};
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _detectFlutterPath();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _detectFlutterPath() async {
    String? foundPath;
    final isWindows = Platform.isWindows;
    final execName = isWindows ? 'flutter.bat' : 'flutter';

    String home = "";
    Map<String, String> envVars = Platform.environment;
    if (isWindows) {
      home = envVars['USERPROFILE'] ?? 'C:\\';
    } else {
      home = envVars['HOME'] ?? '/';
    }

    List<String> possiblePaths = [
      '$home/flutter/bin/$execName',
      '$home/development/flutter/bin/$execName',
      '$home/snap/flutter/common/flutter/bin/$execName',
      '/usr/local/bin/$execName',
      '$home\\flutter\\bin\\$execName',
      '$home\\src\\flutter\\bin\\$execName',
      'C:\\src\\flutter\\bin\\$execName',
      'C:\\flutter\\bin\\$execName',
    ];

    for (String path in possiblePaths) {
      if (await File(path).exists()) {
        foundPath = path;
        break;
      }
    }

    setState(() {
      _flutterExecutablePath = foundPath;
    });

    if (foundPath == null) {
      _checkSystemPath(execName);
    }
  }

  void _checkSystemPath(String execName) {
    final pathVar = Platform.environment['PATH'] ?? '';
    final separator = Platform.isWindows ? ';' : ':';
    final paths = pathVar.split(separator);

    for (var p in paths) {
      final fullPath = '$p${Platform.pathSeparator}$execName';
      if (File(fullPath).existsSync()) {
        setState(() {
          _flutterExecutablePath = fullPath;
        });
        return;
      }
    }
  }

  Future<void> _manualSelectFlutter() async {
    final type = XTypeGroup(
      label: 'Flutter Executable',
      extensions: Platform.isWindows ? ['bat', 'exe'] : null,
    );
    final XFile? file = await openFile(acceptedTypeGroups: [type]);
    if (file != null) {
      setState(() {
        _flutterExecutablePath = file.path;
      });
    }
  }

  Future<void> _pickProject() async {
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath == null) return;

    if (await File('$directoryPath/pubspec.yaml').exists()) {
      setState(() {
        _projectPath = directoryPath;
      });
    } else {
      _showSnack('No pubspec.yaml found in this folder!', isError: true);
    }
  }

  Future<void> _searchPackage(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://pub.dev/api/search?q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final packages = data['packages'] as List;

        List<Map<String, dynamic>> results = [];
        for (var p in packages.take(10)) {
          final name = p['package'].toString();
          try {
            final detailUrl = Uri.parse('https://pub.dev/api/packages/$name');
            final detailResponse = await http.get(detailUrl);
            if (detailResponse.statusCode == 200) {
              final detailData = jsonDecode(detailResponse.body);
              final pubspec = detailData['latest']['pubspec'];
              results.add({
                'name': name,
                'version': detailData['latest']['version'] ?? '',
                'description': pubspec['description'] ?? '',
                'homepage': pubspec['homepage'] ?? pubspec['repository'] ?? '',
                'url': 'https://pub.dev/packages/$name',
              });
            }
          } catch (_) {
            results.add({
              'name': name,
              'version': '',
              'description': '',
              'homepage': '',
              'url': 'https://pub.dev/packages/$name',
            });
          }
        }

        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      _showSnack('Search failed: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addDependency(String packageName) async {
    if (_projectPath == null) return;
    if (_flutterExecutablePath == null) {
      _showSnack(
        'Flutter SDK not found! Please locate it first.',
        isError: true,
      );
      return;
    }

    setState(() => _addingPackages.add(packageName));

    try {
      final result = await Process.run(
        _flutterExecutablePath!,
        ['pub', 'add', packageName],
        workingDirectory: _projectPath,
        runInShell: true,
      );

      if (result.exitCode == 0) {
        _showSnack('Successfully added $packageName!', isSuccess: true);
      } else {
        _showErrorDialog(result.stderr.toString());
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _addingPackages.remove(packageName));
    }
  }

  void _showSnack(String msg, {bool isError = false, bool isSuccess = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bg = colorScheme.inverseSurface;
    IconData icon = Icons.info_outline;

    if (isError) {
      bg = colorScheme.error;
      icon = Icons.error_outline;
    }
    if (isSuccess) {
      bg = Colors.green.shade600;
      icon = Icons.check_circle_outline;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Text("Error"),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme, isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_flutterExecutablePath == null)
                      _buildWarningBanner(colorScheme),
                    _buildProjectSelector(colorScheme, isDark),
                    const SizedBox(height: 20),
                    _buildSearchBar(colorScheme),
                    const SizedBox(height: 20),
                    _buildResultsSection(colorScheme, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0175C2), Color(0xFF54C5F8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pubspec GUI',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Flutter Package Manager',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildFlutterStatusChip(colorScheme),
        ],
      ),
    );
  }

  Widget _buildFlutterStatusChip(ColorScheme colorScheme) {
    final isConnected = _flutterExecutablePath != null;
    return InkWell(
      onTap: _manualSelectFlutter,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isConnected
              ? Colors.green.withValues(alpha: 0.1)
              : colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConnected
                ? Colors.green.shade300
                : colorScheme.error.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flutter_dash,
              size: 18,
              color: isConnected ? Colors.green.shade600 : colorScheme.error,
            ),
            const SizedBox(width: 6),
            Text(
              isConnected ? 'SDK Found' : 'SDK Missing',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isConnected ? Colors.green.shade700 : colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber.shade800,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flutter SDK not detected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Click the SDK status chip above to manually locate it',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelector(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROJECT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickProject,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _projectPath != null
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant,
                width: _projectPath != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _projectPath != null
                        ? Icons.folder
                        : Icons.folder_open_outlined,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _projectPath != null
                            ? _projectPath!.split(Platform.pathSeparator).last
                            : 'No project selected',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _projectPath != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_projectPath != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _projectPath!,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH PACKAGES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search pub.dev packages...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _debounceTimer?.cancel();
                      setState(() => _searchResults.clear());
                    },
                  )
                : null,
          ),
          onSubmitted: _searchPackage,
          onChanged: (value) {
            setState(() {});
            _debounceTimer?.cancel();
            if (value.isNotEmpty) {
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                _searchPackage(value);
              });
            } else {
              setState(() => _searchResults.clear());
            }
          },
        ),
      ],
    );
  }

  Widget _buildResultsSection(ColorScheme colorScheme, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchResults.isNotEmpty || _isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    'RESULTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_searchResults.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Searching packages...',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : _searchResults.isEmpty
                ? _buildEmptyState(colorScheme)
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final pkg = _searchResults[index];
                      return _buildPackageCard(pkg, colorScheme, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Search for packages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find and add packages from pub.dev to your project',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    Map<String, dynamic> pkg,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final name = pkg['name'] as String;
    final version = pkg['version'] as String;
    final description = pkg['description'] as String;
    final pubUrl = pkg['url'] as String;
    final isAdding = _addingPackages.contains(name);
    final canAdd = _projectPath != null && _flutterExecutablePath != null;

    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.green,
    ];
    final color = colors[name.hashCode % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openUrl(pubUrl),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.8),
                        color.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (version.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'v$version',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _openUrl(pubUrl),
                      icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      tooltip: 'Open on pub.dev',
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FilledButton.tonal(
                      onPressed: canAdd && !isAdding
                          ? () => _addDependency(name)
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 36),
                      ),
                      child: isAdding
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 18),
                                SizedBox(width: 4),
                                Text('Add'),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
