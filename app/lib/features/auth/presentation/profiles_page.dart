import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/infrastructure.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/tv_focusable.dart';
import '../../downloads/presentation/downloads_controller.dart';
import '../domain/auth_models.dart';
import 'session_controller.dart';

const _avatarColors = [
  '#E50914',
  '#F5B041',
  '#3498DB',
  '#9B59B6',
  '#46D369',
  '#E67E22',
  '#1ABC9C',
  '#E84393',
];

class ProfilesPage extends ConsumerStatefulWidget {
  const ProfilesPage({super.key});

  @override
  ConsumerState<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends ConsumerState<ProfilesPage> {
  bool _managing = false;
  bool _restoredMode = false;
  String? _busyProfileId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredMode) return;
    _restoredMode = true;
    final manage = GoRouterState.of(context).uri.queryParameters['manage'];
    if (manage == '1') _managing = true;
  }

  Future<void> _select(Profile profile) async {
    if (_managing) {
      await _editProfile(profile);
      return;
    }
    setState(() => _busyProfileId = profile.id);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .selectProfile(profile.id);
      if (mounted &&
          GoRouterState.of(context).uri.queryParameters['switch'] == '1') {
        context.go('/home');
      }
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } finally {
      if (mounted) setState(() => _busyProfileId = null);
    }
  }

  Future<void> _addProfile() async {
    final session = ref.read(sessionControllerProvider);
    final draft = await showDialog<_ProfileDraft>(
      context: context,
      builder: (_) => _ProfileDialog(
        title: context.l10n.addProfile,
      ),
    );
    if (draft == null) return;
    try {
      await ref
          .read(authApiProvider)
          .createProfile(
            name: draft.name,
            isKids: draft.isKids,
            avatarColor: draft.color,
          );
      await ref.read(sessionControllerProvider.notifier).refreshAccount();
    } on ApiException catch (error) {
      if (!mounted) return;
      if (session.profiles.length >= 5) {
        _showError(context.l10n.profileLimitReached);
      } else {
        _showError(error.message);
      }
    }
  }

  Future<void> _editProfile(Profile profile) async {
    final result = await showDialog<_ProfileDialogResult>(
      context: context,
      builder: (_) => _ProfileDialog(
        title: context.l10n.editProfile,
        profile: profile,
        allowDelete: true,
      ),
    );
    if (result == null) return;
    try {
      if (result.deleted) {
        await ref.read(authApiProvider).deleteProfile(profile.id);
        await ref
            .read(downloadsControllerProvider.notifier)
            .removeForProfile(profile.id);
      } else if (result.draft != null) {
        final draft = result.draft!;
        await ref
            .read(authApiProvider)
            .updateProfile(
              profileId: profile.id,
              name: draft.name,
              isKids: draft.isKids,
              avatarColor: draft.color,
            );
      }
      await ref.read(sessionControllerProvider.notifier).refreshAccount();
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final profiles = session.profiles;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(fontSize: 22),
                      const SizedBox(height: 40),
                      Text(
                        context.l10n.whoIsWatching,
                        style: textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.selectProfile,
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),
                      Wrap(
                        spacing: 24,
                        runSpacing: 28,
                        alignment: WrapAlignment.center,
                        children: [
                          for (var i = 0; i < profiles.length; i++)
                            _ProfileTile(
                              profile: profiles[i],
                              managing: _managing,
                              busy: _busyProfileId == profiles[i].id,
                              autofocus: Responsive.isTv(context) && i == 0,
                              onTap: () => _select(profiles[i]),
                            ),
                          if (_managing && profiles.length < 5)
                            _AddProfileTile(onTap: _addProfile),
                        ],
                      ),
                      const SizedBox(height: 44),
                      TextButton.icon(
                        onPressed: () => setState(() => _managing = !_managing),
                        icon: Icon(
                          _managing ? Icons.check_rounded : Icons.edit_outlined,
                          size: 18,
                        ),
                        label: Text(
                          _managing
                              ? context.l10n.done
                              : context.l10n.manageProfiles,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref
                            .read(sessionControllerProvider.notifier)
                            .logout(),
                        child: Text(
                          context.l10n.signOut,
                          style: const TextStyle(color: AppColors.textTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_busyProfileId != null)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.managing,
    required this.busy,
    required this.onTap,
    this.autofocus = false,
  });

  final Profile profile;
  final bool managing;
  final bool busy;
  final VoidCallback onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      enabled: !busy,
      borderRadius: 10,
      scale: 1.06,
      onActivate: onTap,
      builder: (context, focused) {
        return SizedBox(
          width: 108,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ProfileAvatar(profile: profile, size: 96),
                  if (managing)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded, size: 28),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: focused
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: focused ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  const _AddProfileTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      borderRadius: 10,
      scale: 1.06,
      onActivate: onTap,
      builder: (context, focused) {
        return SizedBox(
          width: 108,
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: focused
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 42,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.addProfile,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: focused
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileDraft {
  const _ProfileDraft({
    required this.name,
    required this.isKids,
    required this.color,
  });

  final String name;
  final bool isKids;
  final String color;
}

class _ProfileDialogResult {
  const _ProfileDialogResult.saved(this.draft) : deleted = false;
  const _ProfileDialogResult.deleted() : draft = null, deleted = true;

  final _ProfileDraft? draft;
  final bool deleted;
}

class _ProfileDialog extends StatefulWidget {
  const _ProfileDialog({
    required this.title,
    this.profile,
    this.allowDelete = false,
  });

  final String title;
  final Profile? profile;
  final bool allowDelete;

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  late final TextEditingController _name;
  late bool _isKids;
  late String _color;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile?.name ?? '');
    _isKids = widget.profile?.isKids ?? false;
    _color = widget.profile?.avatarColor ?? _avatarColors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.nameRequired);
      return;
    }
    Navigator.of(context).pop(
      _ProfileDialogResult.saved(
        _ProfileDraft(name: name, isKids: _isKids, color: _color),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteProfileTitle),
        content: Text(
          context.l10n.deleteProfileMessage(widget.profile!.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const _ProfileDialogResult.deleted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: context.l10n.profileName,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.appearance,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in _avatarColors)
                  InkWell(
                    onTap: () => setState(() => _color = color),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == color
                              ? AppColors.textPrimary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              value: _isKids,
              onChanged: (value) => setState(() => _isKids = value),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.kidsProfile),
              subtitle: Text(
                context.l10n.kidsProfileHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.allowDelete)
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(context.l10n.delete),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size(96, 44),
          ),
          child: Text(context.l10n.save),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    if (value == null) return AppColors.red;
    return Color(0xFF000000 | value);
  }
}
