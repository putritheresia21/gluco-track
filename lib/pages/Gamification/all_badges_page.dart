import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';

class AllBadgesPage extends StatelessWidget {
  const AllBadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = GamificationService.instance;
    final currentBadge = gamification.getCurrentBadge();
    final totalPoints = gamification.getTotalPoints();

    final badges = [
      _BadgeInfo(
        level: BadgeLevel.bronze,
        name: 'Bronze',
        description: 'Mulai perjalanan sehatmu',
        minPoints: 0,
        maxPoints: 300,
        color: const Color(0xFFCD7F32),
        icon: Icons.workspace_premium,
      ),
      _BadgeInfo(
        level: BadgeLevel.silver,
        name: 'Silver',
        description: 'Konsistensi yang baik',
        minPoints: 301,
        maxPoints: 600,
        color: const Color(0xFFC0C0C0),
        icon: Icons.military_tech,
      ),
      _BadgeInfo(
        level: BadgeLevel.gold,
        name: 'Gold',
        description: 'Dedikasi luar biasa',
        minPoints: 601,
        maxPoints: 900,
        color: const Color(0xFFFFD700),
        icon: Icons.emoji_events,
      ),
      _BadgeInfo(
        level: BadgeLevel.platinum,
        name: 'Platinum',
        description: 'Master kesehatan',
        minPoints: 901,
        maxPoints: 1500,
        color: const Color(0xFFE5E4E2),
        icon: Icons.stars,
      ),
      _BadgeInfo(
        level: BadgeLevel.diamond,
        name: 'Diamond',
        description: 'Legenda kesehatan',
        minPoints: 1501,
        maxPoints: 99999,
        color: const Color(0xFFB9F2FF),
        icon: Icons.diamond,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C7796),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Badges',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF2C7796),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Points',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalPoints pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: badges.map((badgeInfo) {
                  final isCurrent = badgeInfo.level == currentBadge;
                  final isUnlocked = totalPoints >= badgeInfo.minPoints;

                  return _BadgeCard(
                    badgeInfo: badgeInfo,
                    isCurrent: isCurrent,
                    isUnlocked: isUnlocked,
                    currentPoints: totalPoints,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BadgeInfo {
  final BadgeLevel level;
  final String name;
  final String description;
  final int minPoints;
  final int maxPoints;
  final Color color;
  final IconData icon;

  _BadgeInfo({
    required this.level,
    required this.name,
    required this.description,
    required this.minPoints,
    required this.maxPoints,
    required this.color,
    required this.icon,
  });
}

class _BadgeCard extends StatelessWidget {
  final _BadgeInfo badgeInfo;
  final bool isCurrent;
  final bool isUnlocked;
  final int currentPoints;

  const _BadgeCard({
    required this.badgeInfo,
    required this.isCurrent,
    required this.isUnlocked,
    required this.currentPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent ? Border.all(color: badgeInfo.color, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? badgeInfo.color.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnlocked
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            badgeInfo.color.withOpacity(0.8),
                            badgeInfo.color,
                          ],
                        )
                      : null,
                  color: isUnlocked ? null : Colors.grey.shade300,
                ),
                child: Icon(
                  badgeInfo.icon,
                  color: isUnlocked ? Colors.white : Colors.grey.shade500,
                  size: 35,
                ),
              ),
              if (isCurrent)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      badgeInfo.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? badgeInfo.color : Colors.grey,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  badgeInfo.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badgeInfo.maxPoints == 99999
                      ? '${badgeInfo.minPoints}+ pts'
                      : '${badgeInfo.minPoints} - ${badgeInfo.maxPoints} pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked ? badgeInfo.color : Colors.grey,
                  ),
                ),
                if (isCurrent && badgeInfo.maxPoints != 99999) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (currentPoints - badgeInfo.minPoints) /
                          (badgeInfo.maxPoints - badgeInfo.minPoints),
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(badgeInfo.color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${badgeInfo.maxPoints - currentPoints} pts to next badge',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
