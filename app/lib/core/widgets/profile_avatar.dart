import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/auth/domain/auth_models.dart';

/// Profile tile: a colour block with an initial. Avoids remote
/// avatar dependencies while still feeling personal.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.profile,
    super.key,
    this.size = 84,
    this.selected = false,
  });

  final Profile profile;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(profile.avatarColor);
    final initial = profile.name.trim().isEmpty
        ? '?'
        : profile.name.trim().substring(0, 1).toUpperCase();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppColors.textPrimary : Colors.transparent,
          width: 3,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, AppColors.black, 0.45)!,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: profile.isKids
          ? Icon(
              Icons.child_care_rounded,
              size: size * 0.46,
              color: AppColors.black.withValues(alpha: 0.65),
            )
          : Text(
              initial,
              style: TextStyle(
                fontFamily: 'BarlowCondensed',
                fontSize: size * 0.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
    );
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null || cleaned.length != 6) return AppColors.red;
    return Color(0xFF000000 | value);
  }
}
