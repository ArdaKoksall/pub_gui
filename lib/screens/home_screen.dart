import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/installed_packages_list.dart';
import '../widgets/package_card.dart';
import '../widgets/project_selector.dart';
import '../widgets/sdk_status.dart';
import '../widgets/search_bar_field.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _Titlebar(),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Row(
              children: [
                _Sidebar(),
                const VerticalDivider(width: 1, thickness: 1),
                const Expanded(child: _ResultsPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Titlebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            'pub gui',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          const SdkStatus(),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(
              'EXPLORER',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _SectionHeader(label: 'PROJECT'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
            child: ProjectSelector(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _SectionHeader(label: 'SEARCH'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: SearchBarField(),
          ),
          const Spacer(),
          const Divider(height: 1, thickness: 1),
          Padding(padding: const EdgeInsets.all(12), child: _SdkPathHint()),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SdkPathHint extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final path = ref.watch(sdkPathProvider).asData?.value;
    if (path == null) return const SizedBox.shrink();

    return Text(
      path,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        fontFamily: 'monospace',
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ResultsPanel extends ConsumerWidget {
  const _ResultsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final search = ref.watch(searchProvider);

    if (search.loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (search.error != null) {
      return Center(
        child: Text(
          search.error!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    if (search.results.isEmpty) {
      final projectPath = ref.watch(projectPathProvider);
      if (projectPath != null) {
        return const InstalledPackagesList();
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 36,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Text(
              'Open a project or search packages',
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
            '${search.results.length} packages',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: ListView.separated(
            itemCount: search.results.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
            itemBuilder: (_, i) => PackageCard(package: search.results[i]),
          ),
        ),
      ],
    );
  }
}
