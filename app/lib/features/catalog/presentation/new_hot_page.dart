import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/async_view.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../catalog/presentation/widgets/title_grid.dart';

class NewHotPage extends ConsumerWidget {
  const NewHotPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(newHotProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(),
            Expanded(
              child: AsyncView<({BrowsePage newest, BrowsePage popular})>(
                value: value,
                loading: const AppLoading(),
                onRetry: () => ref.invalidate(newHotProvider),
                builder: (data) => RefreshIndicator(
                  onRefresh: () => ref.refresh(newHotProvider.future),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            Responsive.pagePadding(context),
                            18,
                            Responsive.pagePadding(context),
                            4,
                          ),
                          child: Text(
                            context.l10n.newHot,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _Section(
                          title: context.l10n.newReleases,
                          child: TitleGrid(items: data.newest.items),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _Section(
                          title: context.l10n.popular,
                          child: TitleGrid(items: data.popular.items),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 96 + MediaQuery.paddingOf(context).bottom,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 22, padding, 12),
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: child,
        ),
      ],
    );
  }
}
