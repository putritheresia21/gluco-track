import 'package:flutter/material.dart';

/// Generic reusable widget for displaying lists of content
/// Can be used for articles, media grids, posts, or any other content type
class ContentList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final ScrollController? controller;

  const ContentList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.onRefresh,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading widget if loading
    if (isLoading && loadingWidget != null) {
      return loadingWidget!;
    }

    // Show empty widget if no items
    if (items.isEmpty && emptyWidget != null) {
      return emptyWidget!;
    }

    // Build list
    final listView = ListView.builder(
      controller: controller,
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );

    // Wrap with RefreshIndicator if onRefresh is provided
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
        },
        child: listView,
      );
    }

    return listView;
  }
}
