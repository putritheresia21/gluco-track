import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/Gamification/gamification_main_page.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';

//Semangat cukurukuuukkkk
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final _gamification = GamificationService.instance;
  Map<String, dynamic>? userProfile;
  bool loadingProfile = true;
  bool loadingGamification = true;

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setLightStatusBar();
    loadProfile();
    _initializeGamification();
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
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            height: 1.0,
                          ),
                        ),
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
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E5EA),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saturday, 3 May 2025',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Weekly Summary',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '155 mg/dL',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //  Lowest Card
                    Expanded(
                      child: Container(
                        height: 149,
                        margin: const EdgeInsets.only(right: 7),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(98, 206, 84, 1),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Lowest',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  width: 34,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.trending_down,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Thursday, 1 May 2025, 19:07',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '100',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'mg/dl',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Highest Card
                    Expanded(
                      child: Container(
                        height: 149,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9534F),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Highest',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  width: 34,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: Color(0xFFD9534F),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Saturday, 3 May 2025, 14:00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '170',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'mg/dl',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
