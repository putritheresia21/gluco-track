import 'package:flutter/material.dart';
import '../Widget/AppHeader.dart';

class AppLayout extends StatelessWidget {
  final String? title;
  final bool showBack;
  final bool showHeader;
  final List<Widget>? actions;
  final Widget child;
  final Color? headerBackgroundColor;
  final Color? headerForegroundColor;
  final Widget? headerContent;
  final double? headerHeight;
  final double? elevation;

  const AppLayout({
    Key? key,
    this.title,
    this.showBack = false,
    this.showHeader = true,
    this.actions,
    required this.child,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.headerContent,
    this.headerHeight,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showHeader
          ? AppHeader(
              title: title,
              showBack: showBack,
              actions: actions,
              customContent: headerContent,
              headerHeight: headerHeight ?? kToolbarHeight,
              backgroundColor: headerBackgroundColor ?? Colors.blue,
              foregroundColor: headerForegroundColor ?? Colors.white,
              elevation: elevation ?? 0,
            )
          : null,
      body: child,
    );
  }
}
