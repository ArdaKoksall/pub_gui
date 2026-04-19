import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class SdkStatus extends ConsumerWidget {
  const SdkStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sdk = ref.watch(sdkPathProvider);

    return sdk.when(
      loading: () => const _Chip(found: null),
      error: (err, stack) => _Chip(
        found: false,
        onTap: () => ref.read(sdkPathProvider.notifier).selectManually(),
      ),
      data: (path) => _Chip(
        found: path != null,
        onTap: () => ref.read(sdkPathProvider.notifier).selectManually(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final bool? found;
  final VoidCallback? onTap;

  const _Chip({required this.found, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = found == null;
    final ok = found == true;

    final color = loading
        ? theme.colorScheme.outline
        : ok
        ? const Color(0xFF4EC9B0)
        : theme.colorScheme.error;

    return Tooltip(
      message: ok ? 'Flutter SDK detected' : 'Click to locate Flutter SDK',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: color,
                  ),
                )
              else
                Icon(
                  ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                  size: 14,
                  color: color,
                ),
              const SizedBox(width: 6),
              Text(
                loading
                    ? 'Detecting SDK…'
                    : ok
                    ? 'SDK found'
                    : 'SDK missing',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
