import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/async_view.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../catalog/presentation/widgets/title_poster.dart';
import 'recent_searches.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  String? _genre;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim();
        if (_query.isNotEmpty) _genre = null;
      });
    });
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.length < 2) return;
    setState(() {
      _query = query;
      _genre = null;
    });
    ref.read(recentSearchesProvider.notifier).add(query);
  }

  void _selectRecent(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    _submit(query);
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _query = '';
      _genre = null;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasRequest = _query.length >= 2 || _genre != null;
    final recentSearches = ref.watch(recentSearchesProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTopBar(showBack: true),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.pagePadding(context),
                14,
                Responsive.pagePadding(context),
                12,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                onSubmitted: _submit,
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: context.l10n.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clear,
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                  fillColor: AppColors.surface,
                ),
              ),
            ),
            if (!hasRequest)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.pagePadding(context),
                    8,
                    Responsive.pagePadding(context),
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recentSearches.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              context.l10n.recentSearches,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => ref
                                  .read(recentSearchesProvider.notifier)
                                  .clear(),
                              child: Text(context.l10n.clear),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final query in recentSearches)
                              ActionChip(
                                avatar: const Icon(
                                  Icons.history_rounded,
                                  size: 16,
                                ),
                                label: Text(query),
                                onPressed: () => _selectRecent(query),
                              ),
                          ],
                        ),
                        const SizedBox(height: 26),
                      ],
                      Text(
                        context.l10n.searchEmpty,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.searchEmptyHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 22),
                      ref
                          .watch(genresProvider)
                          .when(
                            data: (genres) => _GenreChips(
                              genres: genres,
                              selected: _genre,
                              onSelected: (genre) {
                                setState(() {
                                  _genre = genre;
                                  _query = '';
                                  _controller.clear();
                                });
                              },
                            ),
                            loading: () => const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: AsyncView<List<TitleCard>>(
                  value: ref.watch(
                    searchResultsProvider((query: _query, genre: _genre)),
                  ),
                  onRetry: () => ref.invalidate(
                    searchResultsProvider((query: _query, genre: _genre)),
                  ),
                  builder: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off_rounded,
                        title: _query.isEmpty
                            ? context.l10n.noMatches
                            : context.l10n.noResults(_query),
                        subtitle: context.l10n.searchEmptyHint,
                      );
                    }
                    return _ResultsGrid(
                      items: items,
                      onOpen: () {
                        if (_query.length >= 2) {
                          ref.read(recentSearchesProvider.notifier).add(_query);
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips({
    required this.genres,
    required this.selected,
    required this.onSelected,
  });

  final List<Genre> genres;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final genre in genres)
          ChoiceChip(
            label: Text(genre.name),
            selected: selected == genre.slug,
            onSelected: (value) => onSelected(value ? genre.slug : null),
          ),
      ],
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.items, required this.onOpen});

  final List<TitleCard> items;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);
    final padding = Responsive.pagePadding(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final available = constraints.maxWidth - padding * 2;
        final cellWidth = (available - spacing * (columns - 1)) / columns;
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            padding,
            8,
            padding,
            100 + MediaQuery.paddingOf(context).bottom,
          ),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 16,
            childAspectRatio: cellWidth / (cellWidth * 1.5 + 4),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return TitlePoster(
              title: item,
              width: cellWidth,
              showBadge: false,
              onTap: () {
                onOpen();
                context.push('/title/${item.id}');
              },
            );
          },
        );
      },
    );
  }
}
