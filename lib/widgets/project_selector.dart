import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class ProjectSelector extends ConsumerWidget {
  const ProjectSelector({super.key});

  Future<void> _pick(WidgetRef ref, BuildContext context) async {
    final dir = await getDirectoryPath();
    if (dir == null) return;

    if (await File('$dir/pubspec.yaml').exists()) {
      ref.read(projectPathProvider.notifier).set(dir);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pubspec.yaml found in that folder')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(projectPathProvider);
    final theme = Theme.of(context);
    final name = path?.split(Platform.pathSeparator).last;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(
            color: path != null
                ? theme.colorScheme.primary.withValues(alpha: 0.6)
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          foregroundColor: path != null
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onPressed: () => _pick(ref, context),
        icon: Icon(
          path != null ? Icons.folder : Icons.folder_open,
          size: 16,
          color: path != null
              ? const Color(0xFFDCB67A)
              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name ?? 'Open project folder…',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: path != null ? FontWeight.w500 : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (path != null)
              Text(
                path,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
