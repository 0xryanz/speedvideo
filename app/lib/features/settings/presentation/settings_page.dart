import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/infrastructure.dart';
import '../../../core/settings/locale_controller.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/presentation/session_controller.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _saving = false;

  Future<void> _updateProfile({bool? autoplayNext}) async {
    final profile = ref.read(sessionControllerProvider).activeProfile;
    if (profile == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(authApiProvider)
          .updateProfile(
            profileId: profile.id,
            autoplayNext: autoplayNext,
          );
      await ref.read(sessionControllerProvider.notifier).refreshAccount();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionControllerProvider.notifier).logout();
      if (mounted && context.mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final profile = session.activeProfile;
    final locale = ref.watch(localeControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final user = session.user;
    final guest = user == null && profile == null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/my-netflix'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(context.l10n.settings),
        backgroundColor: AppColors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          if (profile != null)
            ListTile(
              leading: ProfileAvatar(profile: profile, size: 44),
              title: Text(profile.name),
              subtitle: Text(
                profile.isKids
                    ? context.l10n.kidsProfile
                    : context.l10n.profile,
              ),
              trailing: TextButton(
                onPressed: () => context.go('/profiles?switch=1'),
                child: Text(context.l10n.manage),
              ),
            ),
          if (guest)
            ListTile(
              leading: const Icon(Icons.account_circle_outlined, size: 44),
              title: Text(context.l10n.guestLibraryTitle),
              subtitle: Text(context.l10n.guestLibraryHint),
              trailing: TextButton(
                onPressed: () => context.push('/login'),
                child: Text(context.l10n.signIn),
              ),
            ),
          const Divider(),
          if (!guest) ...[
            _SectionHeader(title: context.l10n.account),
            ListTile(
              title: Text(context.l10n.accountEmail),
              subtitle: Text(
                user?.email ?? '',
                style: textTheme.bodySmall,
              ),
              leading: const Icon(Icons.alternate_email_rounded, size: 22),
            ),
            ListTile(
              title: Text(context.l10n.plan),
              subtitle: Text(
                _capitalize(user?.plan ?? 'standard'),
                style: textTheme.bodySmall,
              ),
              leading: const Icon(Icons.workspace_premium_outlined, size: 22),
            ),
            ListTile(
              title: Text(context.l10n.memberSince),
              subtitle: Text(
                user?.createdAt == null
                    ? ''
                    : DateFormat.yMMMM().format(user!.createdAt!.toLocal()),
                style: textTheme.bodySmall,
              ),
              leading: const Icon(Icons.calendar_today_outlined, size: 22),
            ),
            const Divider(),
            _SectionHeader(title: context.l10n.playback),
            SwitchListTile(
              value: profile?.autoplayNext ?? true,
              onChanged: _saving
                  ? null
                  : (value) => _updateProfile(autoplayNext: value),
              title: Text(context.l10n.autoplayNext),
              secondary: const Icon(Icons.skip_next_outlined, size: 22),
            ),
            const Divider(),
          ],
          _SectionHeader(title: context.l10n.language),
          ListTile(
            leading: const Icon(Icons.translate_rounded, size: 22),
            title: Text(context.l10n.language),
            trailing: DropdownButton<String?>(
              value: locale?.languageCode,
              dropdownColor: AppColors.surface,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(context.l10n.system),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(context.l10n.english),
                ),
                DropdownMenuItem(
                  value: 'zh',
                  child: Text(context.l10n.chinese),
                ),
              ],
              onChanged: (value) =>
                  ref.read(localeControllerProvider.notifier).setLocale(value),
            ),
          ),
          const Divider(),
          if (!guest)
            ListTile(
              leading: const Icon(Icons.logout_rounded, size: 22),
              title: Text(context.l10n.signOut),
              onTap: _signOut,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.aboutApp,
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(context.l10n.aboutBody, style: textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
