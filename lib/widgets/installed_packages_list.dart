import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/pubspec_service.dart';

class InstalledPackagesList extends ConsumerWidget {
  const InstalledPackagesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(installedPackagesProvider);

    return async.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
      data: (packages) {
        if (packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 36,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 12),
                Text(
                  'No dependencies found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Text(
                '${packages.length} dependencies',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: ListView.separated(
                itemCount: packages.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
                itemBuilder: (_, i) =>
                    _InstalledPackageRow(package: packages[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InstalledPackageRow extends ConsumerWidget {
  final InstalledPackage package;
  const _InstalledPackageRow({required this.package});

  Future<void> _remove(WidgetRef ref, BuildContext context) async {
    final sdkPath = ref.read(sdkPathProvider).asData?.value;
    if (sdkPath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Flutter SDK not found')));
      return;
    }

    ref.read(removingPackagesProvider.notifier).add(package.name);
    try {
      await ref.read(installedPackagesProvider.notifier).remove(package.name);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Removed ${package.name}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove ${package.name}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      ref.read(removingPackagesProvider.notifier).remove(package.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final removing = ref.watch(removingPackagesProvider).contains(package.name);
    final sdkPath = ref.watch(sdkPathProvider).asData?.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  package.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9CDCFE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  package.version,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: TextButton(
              onPressed: (sdkPath != null && !removing)
                  ? () => _remove(ref, context)
                  : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                foregroundColor: theme.colorScheme.error.withValues(alpha: 0.7),
                disabledForegroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.2,
                ),
              ),
              child: removing
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: theme.colorScheme.error,
                      ),
                    )
                  : const Text('Remove', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
