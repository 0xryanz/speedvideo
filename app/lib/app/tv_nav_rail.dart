import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../core/l10n/l10n.dart';
import '../core/utils/responsive.dart';
import '../core/widgets/app_logo.dart';
import '../core/widgets/tv_focusable.dart';

/// Left rail used by the 10-foot layout. On a TV the bottom navigation bar is
/// hard to reach and wastes vertical space, so primary navigation moves to a
/// focusable column on the left.
class TvNavRail extends StatelessWidget {
  const TvNavRail({
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      (icon: Icons.home_rounded, label: context.l10n.home),
      (icon: Icons.local_fire_department_rounded, label: context.l10n.newHot),
      (icon: Icons.person_rounded, label: context.l10n.myNetflix),
    ];
    return Container(
      width: Responsive.isTv(context) ? 112 : 88,
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(right: BorderSide(color: AppColors.outline, width: 0.6)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 18, 8, 26),
              child: FittedBox(child: AppLogo(fontSize: 22)),
            ),
            for (var i = 0; i < destinations.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: TvFocusable(
                  borderRadius: 10,
                  scale: 1.03,
                  onActivate: () => onSelected(i),
                  builder: (context, focused) {
                    final selected = i == currentIndex;
                    return Container(
                      height: 68,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.red.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            destinations[i].icon,
                            size: 28,
                            color: selected
                                ? AppColors.textPrimary
                                : (focused
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            destinations[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 11,
                                  color: selected || focused
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'SpeedVideo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
