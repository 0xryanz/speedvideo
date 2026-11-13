import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme.dart';
import '../l10n/l10n.dart';

/// Consistent rendering for provider-backed screens.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.value,
    required this.builder,
    super.key,
    this.loading,
    this.onRetry,
    this.compact = false,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget? loading;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => loading ?? const AppLoading(),
      error: (error, _) => AppErrorView(
        message: error.toString(),
        onRetry: onRetry,
        compact: compact,
      ),
    );
  }
}

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(label!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    super.key,
    this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.textTertiary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                ),
                child: Text(context.l10n.tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmering placeholder block used by skeletons.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 4,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
