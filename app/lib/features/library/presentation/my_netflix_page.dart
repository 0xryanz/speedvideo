import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/network_artwork.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/presentation/session_controller.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/widgets/title_grid.dart';
import '../../downloads/domain/download_models.dart';
import '../../downloads/presentation/downloads_controller.dart';
import '../../downloads/presentation/downloads_providers.dart';
import '../presentation/library_providers.dart';

class MyNetflixPage extends ConsumerWidget {
  const MyNetflixPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final profile = session.activeProfile;
    if (profile == null) return const _GuestLibrary();
    final watchlist = ref.watch(watchlistProvider);
    final padding = Responsive.pagePadding(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(watchlistProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    18,
                    padding,
                    110 + MediaQuery.paddingOf(context).bottom,
                  ),
                  children: [
                    Row(
                      children: [
                        Text(
                          context.l10n.myNetflix,
                          style: textTheme.displaySmall,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => context.push('/settings'),
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: context.l10n.settings,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        ProfileAvatar(
                          profile: profile,
                          name: session.accountName,
                          size: 62,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.accountName ?? profile.name,
                                style: textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.isKids
                                    ? context.l10n.kidsProfile
                                    : (session.user?.email ?? ''),
                                style: textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/profiles?switch=1'),
                          child: Text(context.l10n.manage),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          context.l10n.myListTitle,
                          style: textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 20,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AsyncView<List<TitleCard>>(
                      value: watchlist,
                      loading: const AppLoading(),
                      onRetry: () => ref.invalidate(watchlistProvider),
                      builder: (items) {
                        if (items.isEmpty) {
                          return EmptyState(
                            icon: Icons.bookmark_add_outlined,
                            title: context.l10n.myList,
                            subtitle: context.l10n.searchEmptyHint,
                            action: OutlinedButton(
                              onPressed: () => context.go('/search'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(140, 44),
                              ),
                              child: Text(context.l10n.search),
                            ),
                          );
                        }
                        return TitleGrid(items: items);
                      },
                    ),
                    const SizedBox(height: 28),
                    const _DownloadsSection(),
                    const SizedBox(height: 28),
                    _MenuTile(
                      icon: Icons.settings_outlined,
                      title: context.l10n.settings,
                      onTap: () => context.push('/settings'),
                    ),
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      title: context.l10n.signOut,
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
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
    }
  }
}

/// Sign-in prompt shown in the library tab. Guests can still browse and play;
/// only account-scoped features live behind the login.
class _GuestLibrary extends StatelessWidget {
  const _GuestLibrary();

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  18,
                  padding,
                  110 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.myNetflix,
                        style: textTheme.displaySmall,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: context.l10n.settings,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_circle_outlined,
                          size: 56,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10n.guestLibraryTitle,
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.guestLibraryHint,
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: () => context.push('/login'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                          child: Text(context.l10n.signIn),
                        ),
                        TextButton(
                          onPressed: () => context.push('/signup'),
                          child: Text(context.l10n.signUp),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _MenuTile(
                    icon: Icons.settings_outlined,
                    title: context.l10n.settings,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadsSection extends ConsumerWidget {
  const _DownloadsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(visibleDownloadsProvider);
    final totalBytes = ref.watch(downloadsSizeProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.downloads, style: textTheme.headlineSmall),
            const Spacer(),
            if (downloads.isNotEmpty)
              Text(
                context.l10n.downloadsSize(formatBytes(totalBytes)),
                style: textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (downloads.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.download_for_offline_outlined,
                  size: 30,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.downloadsEmpty,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.downloadsEmptyHint,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (final item in downloads)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DownloadTile(item: item),
                ),
            ],
          ),
      ],
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final episode = item.episode;
    final subtitle = episode == null
        ? context.l10n.movieLabel
        : '${episode.code} · ${episode.name}';
    final playable = item.isCompleted;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: playable ? () => _play(context) : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              height: 78,
              child: NetworkArtwork(
                path: item.posterPath,
                fallbackLabel: item.titleName,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.titleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (item.isDownloading)
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: item.percent / 100,
                              minHeight: 3,
                              backgroundColor: AppColors.outline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${item.percent}%',
                          style: textTheme.labelSmall,
                        ),
                      ],
                    )
                  else if (item.status == DownloadStatus.failed)
                    Text(
                      context.l10n.downloadFailed,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.red,
                      ),
                    )
                  else
                    Text(
                      formatBytes(item.receivedBytes),
                      style: textTheme.labelSmall,
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: item.isDownloading
                  ? context.l10n.cancelDownload
                  : context.l10n.deleteDownload,
              onPressed: () => item.isDownloading
                  ? ref
                        .read(downloadsControllerProvider.notifier)
                        .cancel(item.id)
                  : _confirmDelete(context, ref),
              icon: Icon(
                item.isDownloading
                    ? Icons.close_rounded
                    : Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _play(BuildContext context) {
    final episode = item.episode;
    final query = episode == null
        ? 'offline=1'
        : 'episodeId=${Uri.encodeComponent(episode.id)}&offline=1';
    context.push('/watch/${item.titleId}?$query');
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteDownloadTitle),
        content: Text(context.l10n.deleteDownloadMessage(item.titleName)),
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
    if (confirmed != true) return;
    await ref.read(downloadsControllerProvider.notifier).remove(item.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.downloadRemoved)));
    }
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
