import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/Gamification/gamification_main_page.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';
import 'package:glucotrack_app/Widget/glucose_stats_card.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/services/SupabaseService.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/Widget/weekly_summary_card.dart';
import 'package:glucotrack_app/pages/navbar.dart';

//Semangat cukurukuuukkkk
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final _gamification = GamificationService.instance;
  final _glucoseRepository = Glucoserepository();
  Map<String, dynamic>? userProfile;
  bool loadingProfile = true;
  bool loadingGamification = true;
  bool loadingGlucoseStats = true;
  Glucoserecord? lowestRecord;
  Glucoserecord? highestRecord;

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setLightStatusBar();
    loadProfile();
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

  Future<void> loadProfile() async {
    try {
      final data = await authService.getMyProfile();
      if (!mounted) return;
      setState(() {
        userProfile = data;
        loadingProfile = false;
      });
    } catch (e) {
      setState(() {
        loadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          loadingProfile
                              ? '...'
                              : (userProfile?['username'] ?? 'unknown'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        )
                      ],
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/profile/image.png'),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Card Weekly Summary
                WeeklySummaryCard(
                  isCompactView: true,
                  onTap: () {
                    final userId =
                        SupabaseService.client.auth.currentUser?.id ?? '';
                    final username = userProfile?['username'] ?? 'User';
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => CustomBottomNav(
                          userId: userId,
                          username: username,
                          initialSelectedIndex: 1,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                Row(
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

                const SizedBox(height: 25),

                // Your Mission Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Mission',
                        style: TextStyle(
                          fontSize: 25,
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
                          // Refresh state setelah kembali dari halaman gamification
                          setState(() {});
                        },
                        child: const Text(
                          'view all',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
                            decorationColor: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 7),

                // Mission Card dengan TaskCardWidget
                loadingGamification
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      )
                    : () {
                        final tasks = _gamification.getTasks();
                        // Tampilkan task pertama dengan progress paling banyak
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
                            // Refresh state setelah kembali dari detail page
                            setState(() {});
                          },
                        );
                      }(),

                const SizedBox(height: 20),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C7796),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last 7 Days',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),

                      //  Notifikasi 1
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                                'assets/profile/NotificationProfile.png'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Eric Sohn comment: Busett',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '2 days ago',
                            style: TextStyle(
                              color: Color(0xFFD4EAF7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Divider(color: Colors.white.withOpacity(0.4)),

                      //  Notifikasi 2
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                                'assets/profile/NotificationProfile2.png'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Lorraine liked your post',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '2 days ago',
                            style: TextStyle(
                              color: Color(0xFFD4EAF7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
