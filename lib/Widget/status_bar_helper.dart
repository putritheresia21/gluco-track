import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class StatusBarHelper {
  static void setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F5F5),
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static void setDarkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2C7796),
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  static void setCustomStatusBar({
    required Color statusBarColor,
    required Brightness iconBrightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: iconBrightness,
      ),
    );
  }
}
