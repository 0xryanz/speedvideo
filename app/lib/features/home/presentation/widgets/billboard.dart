import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/network_artwork.dart';
import '../../../catalog/domain/catalog_models.dart';
import '../../../library/presentation/library_providers.dart';

/// Full-bleed hero used at the top of the home feed.
///
/// Mirrors a streaming-service billboard: title art, metadata, and a single row
/// of two equal-width actions (Play / My List). Tapping the artwork opens the
/// title detail page.
class Billboard extends ConsumerWidget {
  const Billboard({required this.title, super.key});

  final TitleCard title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = Responsive.billboardHeight(context);
    final textTheme = Theme.of(context).textTheme;
    final saved =
        ref
            .watch(watchlistProvider)
            .valueOrNull
            ?.any((t) => t.id == title.id) ??
        false;

    return GestureDetector(
      onTap: () => context.push('/title/${title.id}'),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkArtwork(
              path: title.backdropPath,
              fallbackLabel: title.name,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000),
                    Color(0x11000000),
                    Color(0x22000000),
                    AppColors.black,
                  ],
                  stops: [0, 0.32, 0.62, 1],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.black.withValues(alpha: 0.86),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.78],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.pagePadding(context),
                  0,
                  Responsive.pagePadding(context),
                  20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.isTv(context) ? 760 : 560,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (title.badges.any(
                            (badge) => badge.toLowerCase().contains('top'),
                          ))
                            _Badge(
                              label: context.l10n.top10Badge,
                              color: AppColors.red,
                              icon: Icons.trending_up_rounded,
                            ),
                          if (title.badges.any(
                            (badge) => badge.toLowerCase().contains('new'),
                          ))
                            _Badge(
                              label: context.l10n.newBadge,
                              color: AppColors.surfaceElevated,
                            ),
                        ],
                      ),
                      if (title.badges.isNotEmpty) const SizedBox(height: 10),
                      Text(
                        title.name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (Responsive.isTablet(context)
                                    ? textTheme.displayLarge
                                    : textTheme.displayMedium)
                                ?.copyWith(
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x99000000),
                                      blurRadius: 18,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          Text(
                            context.l10n.matchLabel(title.matchPercent),
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          _dot(textTheme),
                          Text(
                            '${title.releaseYear}',
                            style: textTheme.bodySmall,
                          ),
                          _dot(textTheme),
                          _MaturityChip(rating: title.maturityRating),
                          _dot(textTheme),
                          Text(
                            title.kind == 'series'
                                ? context.l10n.episodes
                                : context.l10n.minutes(title.runtimeMinutes),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title.genres.map((genre) => genre.name).join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Actions(
                        play: _PlayButton(
                          onTap: () => context.push('/watch/${title.id}'),
                          label: context.l10n.play,
                          autofocus: Responsive.isTv(context),
                        ),
                        secondary: _SecondaryButton(
                          icon: saved ? Icons.check_rounded : Icons.add_rounded,
                          label: saved
                              ? context.l10n.myList
                              : context.l10n.addToMyList,
                          onTap: () => _toggle(ref, saved),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(TextTheme textTheme) => Text(
    '•',
    style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
  );

  Future<void> _toggle(WidgetRef ref, bool saved) async {
    try {
      await ref
          .read(libraryControllerProvider)
          .toggleWatchlist(title.id, saved: saved);
    } on ApiException catch (error) {
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }
}

/// Two equal-width actions on phones, intrinsic pills on larger screens.
class _Actions extends StatelessWidget {
  const _Actions({required this.play, required this.secondary});

  final Widget play;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 600) {
      return Row(
        children: [
          Expanded(child: play),
          const SizedBox(width: 8),
          Expanded(child: secondary),
        ],
      );
    }
    final isTv = Responsive.isTv(context);
    return Row(
      children: [
        SizedBox(width: isTv ? 190 : 148, child: play),
        const SizedBox(width: 8),
        SizedBox(width: isTv ? 220 : 176, child: secondary),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.onTap,
    required this.label,
    this.autofocus = false,
  });

  final VoidCallback onTap;
  final String label;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      autofocus: autofocus,
      icon: const Icon(Icons.play_arrow_rounded, size: 26),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.black,
        minimumSize: Size.fromHeight(Responsive.isTv(context) ? 52 : 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xCC2A2A2A),
        foregroundColor: AppColors.textPrimary,
        side: BorderSide.none,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaturityChip extends StatelessWidget {
  const _MaturityChip({required this.rating});

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textTertiary),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        rating,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
