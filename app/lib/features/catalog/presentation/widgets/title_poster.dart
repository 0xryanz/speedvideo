import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/network_artwork.dart';
import '../../../../core/widgets/tv_focusable.dart';
import '../../domain/catalog_models.dart';

/// Poster tile used by home rows, search results and the watch list.
class TitlePoster extends StatelessWidget {
  const TitlePoster({
    required this.title,
    required this.onTap,
    super.key,
    this.width,
    this.showBadge = true,
    this.autofocus = false,
  });

  final TitleCard title;
  final VoidCallback onTap;
  final double? width;
  final bool showBadge;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final width = this.width ?? Responsive.posterWidth(context);
    final progress = title.progress;
    return TvFocusable(
      autofocus: autofocus,
      borderRadius: 6,
      scale: Responsive.isTv(context) ? 1.07 : 1.04,
      onActivate: onTap,
      builder: (context, _) {
        return SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkArtwork(
                      path: title.posterPath,
                      fallbackLabel: title.name,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    if (showBadge &&
                        title.badges.isNotEmpty &&
                        title.badges.first.toLowerCase().contains('new'))
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            title.badges.first.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    if (progress != null && progress.percent > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 4,
                          color: AppColors.outline,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (progress.percent / 100).clamp(0, 1),
                            child: Container(color: AppColors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
