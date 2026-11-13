import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/async_view.dart';
import '../domain/home_models.dart';
import 'home_providers.dart';
import 'widgets/billboard.dart';
import 'widgets/title_row.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  bool _solidBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final solid = _scrollController.hasClients && _scrollController.offset > 48;
    if (solid != _solidBar) setState(() => _solidBar = solid);
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    return Scaffold(
      body: Stack(
        children: [
          AsyncView<HomeFeed>(
            value: feed,
            loading: const HomeSkeleton(),
            onRetry: () => ref.invalidate(homeFeedProvider),
            builder: (data) {
              if (data.billboard == null && data.rows.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(homeFeedProvider.future),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.28,
                      ),
                      EmptyState(
                        icon: Icons.movie_filter_outlined,
                        title: context.l10n.emptyCatalogueTitle,
                        subtitle: context.l10n.emptyCatalogueHint,
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref.refresh(homeFeedProvider.future),
                edgeOffset: 64,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    if (data.billboard != null)
                      SliverToBoxAdapter(
                        child: Billboard(title: data.billboard!),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TitleRow(row: data.rows[index]),
                        childCount: data.rows.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 32 + MediaQuery.paddingOf(context).bottom,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: _solidBar ? AppColors.black : Colors.transparent,
                gradient: _solidBar
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xAA000000), Colors.transparent],
                      ),
              ),
              child: const SafeArea(
                bottom: false,
                child: AppTopBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
