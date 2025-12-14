import 'package:flutter/material.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget? content;    
  final String? title;      
  final bool showBack;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final double headerHeight;
  final Widget? customContent;
  final BorderRadius? bottomBorderRadius;
  final Border? bottomBorder;

  const AppHeader({
    super.key,
    this.content,                 
    this.showBack = false,
    this.actions,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    this.title,
    this.elevation = 0,
    this.headerHeight = kToolbarHeight,
    this.customContent,
    this.bottomBorderRadius,
    this.bottomBorder,
  });

  @override
  Size get preferredSize => Size.fromHeight(headerHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Container(
        alignment: Alignment.center,
        child: customContent ?? content ?? _buildTitle(),
      ),
      centerTitle: true,
      actions: actions,
      toolbarHeight: headerHeight,
      shape: bottomBorderRadius != null || bottomBorder != null
          ? RoundedRectangleBorder(
              borderRadius: bottomBorderRadius ?? BorderRadius.zero,
              side: bottomBorder != null
                  ? bottomBorder!.bottom
                  : BorderSide.none,
            )
          : null,
    );
  }

  Widget? _buildTitle() {
    if (content != null) {
      return content;
    }

    if (title != null) {
      return Text(
        title!,
        style: FontUtils.style(
          size: FontSize.xl,
          weight: FontWeightType.semibold,
          color: foregroundColor,
        )
      );
    }
  }
}
