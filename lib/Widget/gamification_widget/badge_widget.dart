import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';

class BadgeWidget extends StatelessWidget {
  final BadgeLevel level;
  final int currentPoints;
  final bool showProgress;
  final double size;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.level,
    required this.currentPoints,
    this.showProgress = true,
    this.size = 80,
    this.onTap,
  });

  String get badgeName {
    switch (level) {
      case BadgeLevel.bronze:
        return 'Bronze';
      case BadgeLevel.silver:
        return 'Silver';
      case BadgeLevel.gold:
        return 'Gold';
      case BadgeLevel.platinum:
        return 'Platinum';
      case BadgeLevel.diamond:
        return 'Diamond';
    }
  }

  Color get badgeColor {
    switch (level) {
      case BadgeLevel.bronze:
        return const Color(0xFFCD7F32);
      case BadgeLevel.silver:
        return const Color(0xFFC0C0C0);
      case BadgeLevel.gold:
        return const Color(0xFFFFD700);
      case BadgeLevel.platinum:
        return const Color(0xFFE5E4E2);
      case BadgeLevel.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  IconData get badgeIcon {
    switch (level) {
      case BadgeLevel.bronze:
        return Icons.workspace_premium;
      case BadgeLevel.silver:
        return Icons.military_tech;
      case BadgeLevel.gold:
        return Icons.emoji_events;
      case BadgeLevel.platinum:
        return Icons.stars;
      case BadgeLevel.diamond:
        return Icons.diamond;
    }
  }

  int get maxPoints {
    switch (level) {
      case BadgeLevel.bronze:
        return 300;
      case BadgeLevel.silver:
        return 600;
      case BadgeLevel.gold:
        return 900;
      case BadgeLevel.platinum:
        return 1500;
      case BadgeLevel.diamond:
        return 9999;
    }
  }

  double get progress {
    final prevMax = _getPreviousMaxPoints();
    final currentMax = maxPoints;

    if (currentPoints >= currentMax) return 1.0;
    if (currentPoints <= prevMax) return 0.0;

    return (currentPoints - prevMax) / (currentMax - prevMax);
  }

  int _getPreviousMaxPoints() {
    switch (level) {
      case BadgeLevel.bronze:
        return 0;
      case BadgeLevel.silver:
        return 300;
      case BadgeLevel.gold:
        return 600;
      case BadgeLevel.platinum:
        return 900;
      case BadgeLevel.diamond:
        return 1500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (showProgress)
                SizedBox(
                  width: size + 8,
                  height: size + 8,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                  ),
                ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      badgeColor.withOpacity(0.8),
                      badgeColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  badgeIcon,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            badgeName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
          if (showProgress)
            Text(
              '$currentPoints / $maxPoints pts',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
}
