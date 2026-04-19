import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/package_info.dart';
import '../providers/providers.dart';

class PackageCard extends ConsumerWidget {
  final PackageInfo package;

  const PackageCard({super.key, required this.package});

  Future<void> _add(WidgetRef ref, BuildContext context) async {
    final sdkPath = ref.read(sdkPathProvider).asData?.value;
    final projectPath = ref.read(projectPathProvider);

    if (sdkPath == null || projectPath == null) return;

    ref.read(addingPackagesProvider.notifier).add(package.name);

    try {
      await ref
          .read(flutterServiceProvider)
          .addPackage(
            sdkPath: sdkPath,
            projectPath: projectPath,
            packageName: package.name,
          );
      ref.read(installedPackagesProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Added ${package.name}')));
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, e.toString());
      }
    } finally {
      ref.read(addingPackagesProvider.notifier).remove(package.name);
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: SelectableText(
            message,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl() async {
    final uri = Uri.parse(package.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final adding = ref.watch(addingPackagesProvider).contains(package.name);
    final sdkPath = ref.watch(sdkPathProvider).asData?.value;
    final projectPath = ref.watch(projectPathProvider);
    final canAdd = sdkPath != null && projectPath != null && !adding;

    return InkWell(
      onTap: _openUrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9CDCFE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (package.version.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          package.version,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (package.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      package.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.55,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                IconButton(
                  onPressed: _openUrl,
                  icon: const Icon(Icons.open_in_new, size: 14),
                  tooltip: 'Open on pub.dev',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(4),
                    minimumSize: const Size(28, 28),
                    foregroundColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 28,
                  child: TextButton(
                    onPressed: canAdd ? () => _add(ref, context) : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      foregroundColor: const Color(0xFF4EC9B0),
                      disabledForegroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.25),
                    ),
                    child: adding
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : const Text('Add', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
