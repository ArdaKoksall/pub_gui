import 'dart:async';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/package_info.dart';
import '../services/flutter_service.dart';
import '../services/pub_service.dart';
import '../services/pubspec_service.dart';

// Services
final pubServiceProvider = Provider((_) => PubService());
final flutterServiceProvider = Provider((_) => FlutterService());
final pubspecServiceProvider = Provider((_) => PubspecService());

// Flutter SDK path
final sdkPathProvider = AsyncNotifierProvider<SdkPathNotifier, String?>(
  SdkPathNotifier.new,
);

class SdkPathNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() => ref.read(flutterServiceProvider).detectSdk();

  Future<void> selectManually() async {
    final type = XTypeGroup(
      label: 'Flutter Executable',
      extensions: Platform.isWindows ? ['bat', 'exe'] : null,
    );
    final file = await openFile(acceptedTypeGroups: [type]);
    if (file != null) state = AsyncData(file.path);
  }
}

// Selected project path
final projectPathProvider = NotifierProvider<ProjectPathNotifier, String?>(
  ProjectPathNotifier.new,
);

class ProjectPathNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? path) => state = path;
}

// Installed packages from the selected project's pubspec.yaml
final installedPackagesProvider =
    AsyncNotifierProvider<InstalledPackagesNotifier, List<InstalledPackage>>(
      InstalledPackagesNotifier.new,
    );

class InstalledPackagesNotifier extends AsyncNotifier<List<InstalledPackage>> {
  @override
  Future<List<InstalledPackage>> build() async {
    final projectPath = ref.watch(projectPathProvider);
    if (projectPath == null) return [];
    return ref.read(pubspecServiceProvider).loadDependencies(projectPath);
  }

  Future<void> remove(String packageName) async {
    final sdkPath = ref.read(sdkPathProvider).asData?.value;
    final projectPath = ref.read(projectPathProvider);
    if (sdkPath == null || projectPath == null) return;

    await ref
        .read(flutterServiceProvider)
        .removePackage(
          sdkPath: sdkPath,
          projectPath: projectPath,
          packageName: packageName,
        );

    ref.invalidateSelf();
  }

  void refresh() => ref.invalidateSelf();
}

// Search
class SearchState {
  final List<PackageInfo> results;
  final bool loading;
  final String? error;

  const SearchState({
    this.results = const [],
    this.loading = false,
    this.error,
  });

  SearchState copyWith({
    List<PackageInfo>? results,
    bool? loading,
    String? error,
  }) => SearchState(
    results: results ?? this.results,
    loading: loading ?? this.loading,
    error: error,
  );
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() => const SearchState();

  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await ref.read(pubServiceProvider).search(query);
      state = SearchState(results: results);
    } catch (e) {
      state = SearchState(error: e.toString());
    }
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }
}

// Packages being added/removed
final addingPackagesProvider =
    NotifierProvider<AddingPackagesNotifier, Set<String>>(
      AddingPackagesNotifier.new,
    );

class AddingPackagesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String name) => state = {...state, name};
  void remove(String name) => state = state.where((n) => n != name).toSet();
}

// Packages being removed
final removingPackagesProvider =
    NotifierProvider<RemovingPackagesNotifier, Set<String>>(
      RemovingPackagesNotifier.new,
    );

class RemovingPackagesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String name) => state = {...state, name};
  void remove(String name) => state = state.where((n) => n != name).toSet();
}
