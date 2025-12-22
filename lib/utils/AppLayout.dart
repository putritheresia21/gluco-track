import 'package:flutter/material.dart';
import '../Widget/AppHeader.dart';

class AppLayout extends StatelessWidget {
  final String? title;
  final Widget? headerContent;
  final Widget child;
  final bool showBack;
  final List<Widget>? actions;
  final bool showHeader;
  final Color headerBackgroundColor;
  final Color headerForegroundColor;
  final Color? bodyBackgroundColor;
  final double? headerHeight;
  final double? elevation;
  final BorderRadius? headerBottomRadius;
  final Border? headerBottomBorder;

  const AppLayout({
    super.key,
    this.headerContent,
    required this.child,
    this.showBack = false,
    this.actions,
    this.showHeader = true,
    this.title,
    this.headerBackgroundColor = Colors.white,
    this.headerForegroundColor = Colors.white,
    this.bodyBackgroundColor,
    this.headerHeight,
    this.elevation,
    this.headerBottomRadius,
    this.headerBottomBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyBackgroundColor,
      appBar: showHeader
          ? AppHeader(
              content: headerContent,
              showBack: showBack,
              actions: actions,
              backgroundColor: headerBackgroundColor,
              foregroundColor: headerForegroundColor,
              title: title,
              headerHeight: headerHeight ?? kToolbarHeight,
              elevation: elevation ?? 0,
              bottomBorderRadius: headerBottomRadius,
              bottomBorder: headerBottomBorder,
            )
          : null,
      body: child,
    );
  }
}
