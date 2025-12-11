import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glucotrack_app/pages/login_page.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/pages/profile_page.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';
import 'package:glucotrack_app/pages/Gamification/gamification_main_page.dart';
import 'package:glucotrack_app/Widget/glucose_stats_card.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/services/SupabaseService.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';

//Semangat cukurukuuukkkk

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService authService = AuthService();
  final _gamification = GamificationService.instance;
  final _glucoseRepository = Glucoserepository();
  String username = 'Loading...';
  bool loadingUsername = true;
  bool loadingGamification = true;
  bool loadingGlucoseStats = true;
  Glucoserecord? lowestRecord;
  Glucoserecord? highestRecord;

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setDarkStatusBar();
    loadUsername();
    _initializeGamification();
    _loadGlucoseStats();
  }

  Future<void> _loadGlucoseStats() async {
    try {
      final userId =
          SupabaseService.client.auth.currentUser?.id ?? 'default_user';
      final lowest = await _glucoseRepository.getLowestGlucoseRecord(userId);
      final highest = await _glucoseRepository.getHighestGlucoseRecord(userId);

      if (mounted) {
        setState(() {
          lowestRecord = lowest;
          highestRecord = highest;
          loadingGlucoseStats = false;
        });
      }
    } catch (e) {
      print('Error loading glucose stats: $e');
      if (mounted) {
        setState(() {
          loadingGlucoseStats = false;
        });
      }
    }
  }

  Future<void> _initializeGamification() async {
    await _gamification.initialize();
    if (mounted) {
      setState(() {
        loadingGamification = false;
      });
    }
  }

  Future<void> loadUsername() async {
    try {
      final data = await authService.getMyProfile();
      if (!mounted) return;
      setState(() {
        username = data?['username'] ?? 'User';
        loadingUsername = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        username = 'User';
        loadingUsername = false;
      });
    }
  }

  Color _getBadgeColor(BadgeLevel level) {
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

  IconData _getBadgeIcon(BadgeLevel level) {
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

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                logout(context);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get gamification data
    final currentBadge = loadingGamification
        ? BadgeLevel.bronze
        : _gamification.getCurrentBadge();
    final totalPoints =
        loadingGamification ? 0 : _gamification.getTotalPoints();
    final tasks = loadingGamification ? <MainTask>[] : _gamification.getTasks();
    final completedTasks =
        tasks.fold(0, (sum, task) => sum + task.completedSubTasks);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C7796),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 43,
                                backgroundImage:
                                    AssetImage('assets/profile/image.png'),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loadingUsername ? '...' : username,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    "26 years old",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // New Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          loadingGamification
                                              ? Icons.workspace_premium
                                              : _getBadgeIcon(currentBadge),
                                          color: loadingGamification
                                              ? Colors.grey
                                              : _getBadgeColor(currentBadge),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          loadingGamification
                                              ? '...'
                                              : currentBadge
                                                  .toString()
                                                  .split('.')
                                                  .last
                                                  .toUpperCase(),
                                          style: TextStyle(
                                            color: loadingGamification
                                                ? Colors.grey
                                                : _getBadgeColor(currentBadge),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 130,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                              color: Colors.black.withOpacity(0.5),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Dynamic data from gamification
                            _InfoColumn(
                                value: loadingGamification
                                    ? '...'
                                    : totalPoints.toString(),
                                label: "Points"),
                            _DividerLine(),
                            _InfoColumn(value: "4", label: "Days Streak"),
                            _DividerLine(),
                            _InfoColumn(
                                value: loadingGamification
                                    ? '...'
                                    : completedTasks.toString(),
                                label: "Missions Completed"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),

                // Lowest & Highest Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlucoseStatsCard(
                        title: 'Lowest',
                        glucoseRecord: lowestRecord,
                        isLowest: true,
                        isLoading: loadingGlucoseStats,
                      ),
                      const SizedBox(width: 14),
                      GlucoseStatsCard(
                        title: 'Highest',
                        glucoseRecord: highestRecord,
                        isLowest: false,
                        isLoading: loadingGlucoseStats,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Your Mission
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Next Mission',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GamificationMainPage(),
                            ),
                          );
                          setState(() {});
                        },
                        child: const Text(
                          'view all',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 3),

                // Mission Card dengan TaskCardWidget
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: loadingGamification
                      ? Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      : () {
                          if (tasks.isEmpty) {
                            return Container(
                              height: 150,
                              alignment: Alignment.center,
                              child: const Text('No missions available'),
                            );
                          }

                          final sortedTasks = List<MainTask>.from(tasks)
                            ..sort((a, b) => b.progress.compareTo(a.progress));
                          final displayTask = sortedTasks.first;

                          return TaskCardWidget(
                            task: displayTask,
                            onSeeDetail: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailPage(task: displayTask),
                                ),
                              );
                              setState(() {});
                            },
                          );
                        }(),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Color(0xFF003049),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_forward, color: Color(0xFF003049)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        confirmLogout(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Color(0xFF003049),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.arrow_forward, color: Color(0xFF003049)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Widgets
class _InfoColumn extends StatelessWidget {
  final String value;
  final String label;

  const _InfoColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}
