import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/responsive.dart';
import '../../domain/catalog_models.dart';
import 'title_poster.dart';

/// Responsive, non-scrolling poster grid intended to be embedded inside a
/// parent scroll view.
class TitleGrid extends StatelessWidget {
  const TitleGrid({
    required this.items,
    super.key,
    this.padding = EdgeInsets.zero,
  });

  final List<TitleCard> items;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final columns = Responsive.gridColumns(context);
    final slack = Responsive.posterCellSlack(context);
    final spacing = Responsive.isTv(context) ? 12.0 : 8.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - padding.horizontal;
        final cellWidth = (available - spacing * (columns - 1)) / columns;
        return GridView.builder(
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: Responsive.isTv(context) ? 24 : 16,
            childAspectRatio: cellWidth / (cellWidth * 1.5 + slack),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: slack / 2),
              child: TitlePoster(
                title: item,
                width: cellWidth,
                showBadge: false,
                onTap: () => context.push('/title/${item.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
