import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/package_info.dart';

class PubService {
  static const _base = 'https://pub.dev/api';

  Future<List<PackageInfo>> search(String query) async {
    final res = await http.get(Uri.parse('$_base/search?q=$query'));
    if (res.statusCode != 200) throw Exception('Search failed');

    final names = (jsonDecode(res.body)['packages'] as List)
        .take(10)
        .map((p) => p['package'] as String)
        .toList();

    final results = await Future.wait(names.map(_fetchDetail));
    return results.whereType<PackageInfo>().toList();
  }

  Future<PackageInfo?> _fetchDetail(String name) async {
    try {
      final res = await http.get(Uri.parse('$_base/packages/$name'));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final pubspec = data['latest']['pubspec'];
      return PackageInfo(
        name: name,
        version: data['latest']['version'] ?? '',
        description: pubspec['description'] ?? '',
        url: 'https://pub.dev/packages/$name',
      );
    } catch (_) {
      return null;
    }
  }
}
