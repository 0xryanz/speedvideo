import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../features/auth/presentation/session_controller.dart';
import '../l10n/l10n.dart';
import '../utils/responsive.dart';
import 'app_logo.dart';
import 'profile_avatar.dart';
import 'tv_focusable.dart';

/// Shared top bar: wordmark, search and the profile menu.
///
/// Netflix keeps the same chrome on every signed-in tab, so search is never a
/// separate bottom destination.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, this.showBack = false, this.backFallback});

  final bool showBack;
  final String? backFallback;

  @override
  Widget build(BuildContext context) {
    final isTv = Responsive.isTv(context);
    return SizedBox(
      height: isTv ? 72 : 52,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.pagePadding(context),
        ),
        child: Row(
          children: [
            if (showBack) ...[
              IconButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(backFallback ?? '/home'),
                icon: Icon(Icons.arrow_back_rounded, size: isTv ? 28 : 24),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 2),
            ] else if (!isTv) ...[
              const AppLogo(fontSize: 24),
              const SizedBox(width: 4),
            ],
            const Spacer(),
            if (!showBack) ...[
              IconButton(
                onPressed: () => context.push('/search'),
                icon: Icon(Icons.search_rounded, size: isTv ? 30 : 25),
                tooltip: context.l10n.search,
              ),
              const SizedBox(width: 2),
            ],
            const _ProfileMenuButton(),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuButton extends ConsumerWidget {
  const _ProfileMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      sessionControllerProvider.select((session) => session.activeProfile),
    );
    if (profile == null) {
      return IconButton(
        onPressed: () => context.push('/login'),
        icon: Icon(
          Icons.person_outline_rounded,
          size: Responsive.isTv(context) ? 30 : 25,
        ),
        tooltip: context.l10n.signIn,
      );
    }
    final size = Responsive.isTv(context) ? 34.0 : 30.0;
    return TvFocusable(
      borderRadius: size / 2 + 4,
      scale: 1.06,
      onActivate: () => _openMenu(context, ref),
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: ProfileAvatar(profile: profile, size: size),
        );
      },
    );
  }

  Future<void> _openMenu(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionControllerProvider);
    final profile = session.activeProfile;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (profile != null)
                  ListTile(
                    leading: ProfileAvatar(profile: profile, size: 40),
                    title: Text(profile.name),
                    subtitle: Text(
                      profile.isKids
                          ? context.l10n.kidsProfile
                          : context.l10n.profile,
                    ),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.switch_account_outlined, size: 22),
                  title: Text(context.l10n.switchProfile),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/profiles?switch=1');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, size: 22),
                  title: Text(context.l10n.manageProfiles),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/profiles?switch=1&manage=1');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, size: 22),
                  title: Text(context.l10n.settings),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, size: 22),
                  title: Text(context.l10n.signOut),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref.read(sessionControllerProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
