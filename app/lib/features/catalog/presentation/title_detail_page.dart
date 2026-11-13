import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/network_artwork.dart';
import '../../auth/presentation/login_required.dart';
import '../../auth/presentation/session_controller.dart';
import '../../downloads/domain/download_models.dart';
import '../../downloads/presentation/downloads_controller.dart';
import '../../library/presentation/library_providers.dart';
import '../domain/catalog_models.dart';
import 'catalog_providers.dart';
import 'widgets/title_grid.dart';

class TitleDetailPage extends ConsumerWidget {
  const TitleDetailPage({required this.titleId, super.key});

  final String titleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(titleDetailProvider(titleId));
    return Scaffold(
      body: AsyncView<TitleDetail>(
        value: detail,
        onRetry: () => ref.invalidate(titleDetailProvider(titleId)),
        builder: (data) => _DetailView(detail: data),
      ),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.detail});

  final TitleDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final padding = Responsive.pagePadding(context);
    final backdropHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      260.0,
      460.0,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: backdropHeight,
          pinned: true,
          backgroundColor: AppColors.black,
          leading: IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                NetworkArtwork(
                  path: detail.backdropPath,
                  fallbackLabel: detail.name,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x99000000),
                        Color(0x00000000),
                        Color(0xCC000000),
                        AppColors.black,
                      ],
                      stops: [0, 0.3, 0.8, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.badges.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final badge in detail.badges.take(3))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            badge.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                    ],
                  ),
                if (detail.badges.isNotEmpty) const SizedBox(height: 10),
                Text(
                  detail.name,
                  style: textTheme.displaySmall?.copyWith(fontSize: 38),
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Text(
                      context.l10n.matchLabel(detail.matchPercent),
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text('${detail.releaseYear}', style: textTheme.bodySmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textTertiary),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        detail.maturityRating,
                        style: textTheme.labelSmall,
                      ),
                    ),
                    Text(
                      detail.kind == 'series'
                          ? context.l10n.seasonsCount(detail.seasons.length)
                          : formatRuntime(context, detail.runtimeMinutes),
                      style: textTheme.bodySmall,
                    ),
                    if (detail.kind == 'movie')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.textTertiary),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text('HD', style: textTheme.labelSmall),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        onPressed: () => _play(context),
                        autofocus: Responsive.isTv(context),
                        icon: const Icon(Icons.play_arrow_rounded, size: 26),
                        label: Text(
                          detail.resume != null
                              ? context.l10n.resume
                              : context.l10n.play,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: AppColors.black,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _DownloadButton(detail: detail)),
                  ],
                ),
                if (detail.offers.length > 1) ...[
                  const SizedBox(height: 18),
                  _SourceSelector(detail: detail),
                ],
                if (detail.resume != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (detail.resume!.percent / 100).clamp(0, 1),
                      minHeight: 3,
                      backgroundColor: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDuration(detail.resume!.positionSeconds)} / ${formatDuration(detail.resume!.durationSeconds)}',
                    style: textTheme.labelSmall,
                  ),
                ],
                const SizedBox(height: 10),
                _WatchlistButton(detail: detail),
                const SizedBox(height: 18),
                if (detail.tagline.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      detail.tagline,
                      style: textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                _ExpandableText(text: detail.synopsis),
                const SizedBox(height: 16),
                if (detail.genres.isNotEmpty)
                  Text(
                    detail.genres.map((genre) => genre.name).join(' • '),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 24),
                _AboutSection(detail: detail),
                if (detail.kind == 'series' && detail.seasons.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _EpisodesSection(detail: detail),
                ],
                const SizedBox(height: 28),
                Text(
                  context.l10n.moreLikeThis,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final similar = ref.watch(similarTitlesProvider(detail.id));
                    return AsyncView<List<TitleCard>>(
                      value: similar,
                      onRetry: () =>
                          ref.invalidate(similarTitlesProvider(detail.id)),
                      loading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: AppLoading(),
                      ),
                      builder: (items) => TitleGrid(items: items),
                    );
                  },
                ),
                SizedBox(
                  height: 40 + MediaQuery.paddingOf(context).bottom,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _play(BuildContext context) {
    var episodeId = detail.resume?.episodeId;
    if (episodeId == null && detail.kind == 'series') {
      for (final season in detail.seasons) {
        if (season.episodes.isNotEmpty) {
          episodeId = season.episodes.first.id;
          break;
        }
      }
    }
    final query = episodeId == null
        ? ''
        : '?episodeId=${Uri.encodeComponent(episodeId)}';
    context.push('/watch/${detail.id}$query');
  }
}

class _DownloadButton extends ConsumerStatefulWidget {
  const _DownloadButton({required this.detail});

  final TitleDetail detail;

  @override
  ConsumerState<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends ConsumerState<_DownloadButton> {
  bool _busy = false;

  /// Series download the resume episode, falling back to the first episode.
  Episode? get _episode {
    final detail = widget.detail;
    if (detail.kind != 'series') return null;
    final resumeId = detail.resume?.episodeId;
    for (final season in detail.seasons) {
      for (final episode in season.episodes) {
        if (resumeId != null && episode.id == resumeId) return episode;
      }
    }
    for (final season in detail.seasons) {
      if (season.episodes.isNotEmpty) return season.episodes.first;
    }
    return null;
  }

  Future<void> _handle(DownloadItem? item) async {
    if (kIsWeb) {
      _toast(context.l10n.downloadUnavailable);
      return;
    }
    if (!await ensureSignedIn(
      context,
      ref,
      message: context.l10n.downloadNeedsAccount,
    )) {
      return;
    }
    if (!mounted) return;
    final notifier = ref.read(downloadsControllerProvider.notifier);
    if (item != null && item.isDownloading) {
      await notifier.cancel(item.id);
      return;
    }
    if (item != null && item.isCompleted) {
      _toast(context.l10n.storedOnDevice);
      return;
    }
    setState(() => _busy = true);
    try {
      final profileId = ref.read(sessionControllerProvider).activeProfileId;
      await notifier.start(
        detail: widget.detail,
        episode: _episode,
        profileId: profileId,
      );
      if (mounted) _toast(context.l10n.downloadStarted(widget.detail.name));
    } on ApiException catch (error) {
      if (!mounted) return;
      _toast(
        error.code == 'not_found'
            ? context.l10n.downloadUnavailable
            : error.message,
      );
    } on Object {
      if (mounted) _toast(context.l10n.downloadFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(downloadsControllerProvider);
    final episode = _episode;
    final item = findDownload(items, widget.detail.id, episode?.id);
    final downloading = item?.isDownloading ?? false;
    final downloaded = item?.isCompleted ?? false;
    final episodeCode = episode == null
        ? null
        : 'S${episode.seasonNumber}:E${episode.number}';
    final label = downloaded
        ? context.l10n.downloaded
        : downloading
        ? '${context.l10n.downloading} ${item!.percent}%'
        : episodeCode == null
        ? context.l10n.download
        : '${context.l10n.download} $episodeCode';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _handle(item),
          icon: Icon(
            downloaded
                ? Icons.download_done_rounded
                : downloading
                ? Icons.close_rounded
                : Icons.download_rounded,
            size: 20,
          ),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: const Color(0xCC2A2A2A),
            foregroundColor: AppColors.textPrimary,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        if (downloading && item != null) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (item.percent / 100).clamp(0, 1),
              minHeight: 3,
              backgroundColor: AppColors.outline,
            ),
          ),
        ],
      ],
    );
  }
}

class _WatchlistButton extends ConsumerStatefulWidget {
  const _WatchlistButton({required this.detail});

  final TitleDetail detail;

  @override
  ConsumerState<_WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends ConsumerState<_WatchlistButton> {
  bool _busy = false;

  Future<void> _toggle(bool saved) async {
    if (!await ensureSignedIn(
      context,
      ref,
      message: context.l10n.watchlistNeedsAccount,
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(libraryControllerProvider)
          .toggleWatchlist(
            widget.detail.id,
            saved: saved,
          );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistProvider).valueOrNull;
    final saved = watchlist == null
        ? widget.detail.inWatchlist
        : watchlist.any((item) => item.id == widget.detail.id);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : () => _toggle(saved),
        icon: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                saved ? Icons.check_rounded : Icons.add_rounded,
                size: 20,
              ),
        label: Text(
          saved ? context.l10n.removeFromMyList : context.l10n.addToMyList,
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: AppColors.surface.withValues(alpha: 0.45),
          side: BorderSide(
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? null : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _expanded ? context.l10n.less : context.l10n.more,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.detail});

  final TitleDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RichText(
          text: TextSpan(
            style: textTheme.bodySmall,
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(color: AppColors.textTertiary),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.about, style: textTheme.headlineSmall),
        const SizedBox(height: 10),
        if (detail.director.isNotEmpty)
          row(context.l10n.director, detail.director),
        if (detail.cast.isNotEmpty)
          row(context.l10n.cast, detail.cast.join(', ')),
        if (detail.country.isNotEmpty) row('Country', detail.country),
      ],
    );
  }
}

class _EpisodesSection extends StatefulWidget {
  const _EpisodesSection({required this.detail});

  final TitleDetail detail;

  @override
  State<_EpisodesSection> createState() => _EpisodesSectionState();
}

class _EpisodesSectionState extends State<_EpisodesSection> {
  int _seasonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final textTheme = Theme.of(context).textTheme;
    final season = detail.seasons[_seasonIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.l10n.episodes, style: textTheme.headlineSmall),
            const Spacer(),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _seasonIndex,
                dropdownColor: AppColors.surface,
                style: textTheme.titleSmall,
                icon: const Icon(Icons.expand_more_rounded),
                items: [
                  for (var i = 0; i < detail.seasons.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(
                        context.l10n.seasonNumber(detail.seasons[i].number),
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _seasonIndex = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final episode in season.episodes)
          _EpisodeTile(
            episode: episode,
            progress: detail.resume?.episodeId == episode.id
                ? detail.resume
                : null,
            onTap: () => context.push(
              '/watch/${detail.id}?episodeId=${Uri.encodeComponent(episode.id)}',
            ),
          ),
      ],
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.onTap,
    this.progress,
  });

  final Episode episode;
  final TitleProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 128,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkArtwork(
                      path: episode.stillPath,
                      fallbackLabel: episode.name,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const Center(
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0x99000000),
                        child: Icon(Icons.play_arrow_rounded, size: 20),
                      ),
                    ),
                    if (progress != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: LinearProgressIndicator(
                          value: (progress!.percent / 100).clamp(0, 1),
                          minHeight: 3,
                          backgroundColor: AppColors.outline,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${episode.number}. ${episode.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        formatRuntime(context, episode.runtimeMinutes),
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    episode.synopsis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
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

/// Lets the viewer pick which licensed provider supplies the stream. Each
/// offer is its own catalogue row, so switching replaces the detail route with
/// the chosen rendition and keeps the source in the URL.
class _SourceSelector extends StatelessWidget {
  const _SourceSelector({required this.detail});

  final TitleDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.playbackSource, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final offer in detail.offers)
              ChoiceChip(
                label: Text(_label(context, offer)),
                selected: offer.titleId == detail.id,
                onSelected: (selected) {
                  if (!selected || offer.titleId == detail.id) return;
                  context.pushReplacement('/title/${offer.titleId}');
                },
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.playbackSourceHint,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  String _label(BuildContext context, TitleOffer offer) {
    final name = offer.sourceName.isEmpty
        ? context.l10n.playbackSourceDefault
        : offer.sourceName;
    if (offer.episodeCount > 1) {
      return '$name · ${context.l10n.episodesCount(offer.episodeCount)}';
    }
    return name;
  }
}
