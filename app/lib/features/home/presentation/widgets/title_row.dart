import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../catalog/presentation/widgets/title_poster.dart';
import '../../domain/home_models.dart';

/// One horizontally scrolling shelf.
class TitleRow extends StatelessWidget {
  const TitleRow({required this.row, super.key});

  final HomeRow row;

  @override
  Widget build(BuildContext context) {
    if (row.items.isEmpty) return const SizedBox.shrink();
    final posterWidth = Responsive.posterWidth(context);
    final slack = Responsive.posterCellSlack(context);
    final rowHeight = posterWidth * 1.5 + slack;
    final isTv = Responsive.isTv(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.pagePadding(context),
            18,
            Responsive.pagePadding(context),
            10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  row.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.pagePadding(context),
            ),
            physics: isTv
                ? const ClampingScrollPhysics()
                : const BouncingScrollPhysics(),
            itemCount: row.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = row.items[index];
              return Padding(
                padding: EdgeInsets.symmetric(vertical: slack / 2),
                child: TitlePoster(
                  title: item,
                  onTap: () => context.push('/title/${item.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shimmer skeleton that mirrors the home layout while the feed loads.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final posterWidth = Responsive.posterWidth(context);
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            height: MediaQuery.sizeOf(context).height * 0.58,
            radius: 0,
          ),
          const SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.pagePadding(context),
            ),
            child: const ShimmerBox(width: 160, height: 20),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: posterWidth * 1.5,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.pagePadding(context),
              ),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, _) => ShimmerBox(
                width: posterWidth,
                height: posterWidth * 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
