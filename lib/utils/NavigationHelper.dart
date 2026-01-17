import 'package:flutter/material.dart';

/// Global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Navigate to a specific route from anywhere (including notifications)
void navigateToRoute(String routeName, {Object? arguments}) {
  navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
}

/// Navigate and replace current route
void navigateAndReplace(String routeName, {Object? arguments}) {
  navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
}

/// Pop to root and navigate
void navigateToRoot(Widget page) {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => page),
    (route) => false,
  );
}

/// Push a widget directly
void navigateTo(Widget page) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => page),
  );
}
