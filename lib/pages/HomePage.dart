import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/Gamification/gamification_main_page.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/Widget/CustomCard.dart';
import 'package:glucotrack_app/pages/NavbarItem/Navbar.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/User_service.dart';

//Semangat cukurukuuukkkk
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final UserService _userService = UserService();
  final _gamification = GamificationService.instance;
  final _glucoseRepository = Glucoserepository();

  File? profileImage;
  String? profileImageUrl;

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
      final userId = _userService.currentUserId ?? 'default_user';
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
    await _gamification.initialize(context: context);
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
        profileImageUrl = data?['avatar_url'];
        loadingProfile = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          loadingProfile = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _getWeeklySummary() async {
    try {
      final userId = _userService.currentUserId ?? 'default_user';
      final allRecords = await _glucoseRepository.getAllGlucoseRecords(userId);

      // Filter records from last 7 days
      DateTime now = DateTime.now();
      DateTime startOfWeek = now.subtract(const Duration(days: 7));

      final weeklyRecords = allRecords.where((record) {
        return record.timeStamp.isAfter(startOfWeek);
      }).toList();

      double average = 0;
      if (weeklyRecords.isNotEmpty) {
        double sum = weeklyRecords.fold(
            0.0, (prev, record) => prev + record.glucoseLevel);
        average = sum / weeklyRecords.length;
      }

      return {
        'average': average,
        'count': allRecords.length,
      };
    } catch (e) {
      print('Error loading weekly summary: $e');
      return {'average': 0.0, 'count': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBack: false,
      showHeader: true,
      headerBackgroundColor: const Color(0xFFF5F5F5),
      headerForegroundColor: Colors.black,
      bodyBackgroundColor: const Color(0xFFF5F5F5),
      headerContent: buildHeaderContent(),
      headerHeight: 100,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const SizedBox(height: 30),
                // Weekly Summary Card
                FutureBuilder<Map<String, dynamic>>(
                  future: _getWeeklySummary(),
                  builder: (context, snapshot) {
                    return CustomCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD6E5EA), Color(0xFFD6E5EA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: 10,
                      padding: const EdgeInsets.all(24),
                      onTap: () {
                        final userId = _userService.currentUserId ?? '';
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
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const SizedBox(
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF2C7796),
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE, d MMM yyyy')
                                      .format(DateTime.now()),
                                  style: FontUtils.style(
                                    size: FontSize.md,
                                    weight: FontWeightType.medium,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.weeklySummary,
                                  style: FontUtils.style(
                                    size: FontSize.lg,
                                    weight: FontWeightType.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      snapshot.hasData &&
                                              snapshot.data!['average'] > 0
                                          ? snapshot.data!['average']
                                              .toStringAsFixed(0)
                                          : '-',
                                      style: FontUtils.style(
                                        size: FontSize.xxl,
                                        weight: FontWeightType.bold,
                                        color: const Color(0xFFEF5350),
                                        height: 1,
                                      ).copyWith(fontSize: 48),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        AppLocalizations.of(context)!.mgDl,
                                        style: FontUtils.style(
                                          size: FontSize.md,
                                          weight: FontWeightType.semibold,
                                          color: const Color(0xFFEF5350),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (snapshot.hasData &&
                                        snapshot.data!['count'] > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2C7796),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${snapshot.data!['count']} ${AppLocalizations.of(context)!.totalRecords}',
                                          style: FontUtils.style(
                                            size: FontSize.xs,
                                            weight: FontWeightType.semibold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: _buildGlucoseCard(
                        title: AppLocalizations.of(context)!.lowest,
                        record: lowestRecord,
                        color: const Color(0xFF62CE54),
                        icon: Icons.trending_down,
                        isLoading: loadingGlucoseStats,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGlucoseCard(
                        title: AppLocalizations.of(context)!.highest,
                        record: highestRecord,
                        color: const Color(0xFFD9534F),
                        icon: Icons.trending_up,
                        isLoading: loadingGlucoseStats,
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
                      Text(
                        AppLocalizations.of(context)!.yourMission,
                        style: FontUtils.style(
                          size: FontSize.lg,
                          weight: FontWeightType.bold,
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
                        child: Text(
                          AppLocalizations.of(context)!.viewAll,
                          style: FontUtils.style(
                            size: FontSize.md,
                            weight: FontWeightType.regular,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ).copyWith(
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
                        // Tampilkan task pertama dengan progress paling sedikit
                        final sortedTasks = List<MainTask>.from(tasks)
                          ..sort((a, b) => a.progress.compareTo(b.progress));
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
                    AppLocalizations.of(context)!.notifications,
                    style: FontUtils.style(
                      size: FontSize.lg,
                      weight: FontWeightType.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                CustomCard(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4A90B8),
                      Color(0xFF2C7796),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: 12,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.last7Days,
                        style: FontUtils.style(
                          size: FontSize.md,
                          weight: FontWeightType.bold,
                          color: Colors.white,
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
                              style: FontUtils.style(
                                size: FontSize.sm,
                                weight: FontWeightType.semibold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.daysAgo(2),
                            style: FontUtils.style(
                              size: FontSize.xs,
                              weight: FontWeightType.medium,
                              color: const Color(0xFFD4EAF7),
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
                              style: FontUtils.style(
                                size: FontSize.sm,
                                weight: FontWeightType.semibold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.daysAgo(2),
                            style: FontUtils.style(
                              size: FontSize.xs,
                              weight: FontWeightType.medium,
                              color: const Color(0xFFD4EAF7),
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

  Widget buildHeaderContent({Color textColor = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.hello,
              style: FontUtils.style(
                size: FontSize.lg,
                weight: FontWeightType.regular,
                color: textColor,
              ),
            ),
            Text(
              loadingProfile ? '...' : (userProfile?['username'] ?? 'User'),
              style: FontUtils.style(
                size: FontSize.xl,
                weight: FontWeightType.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey[300],
          backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
              ? NetworkImage(profileImageUrl!)
              : const AssetImage('assets/profile/image.png') as ImageProvider,
        ),
      ],
    );
  }

  Widget _buildGlucoseCard({
    required String title,
    required Glucoserecord? record,
    required Color color,
    required IconData icon,
    required bool isLoading,
  }) {
    String getConditionLabel(GlucoseCondition condition) {
      return condition == GlucoseCondition.beforeMeal
          ? AppLocalizations.of(context)!.beforeMeal
          : AppLocalizations.of(context)!.afterMeal;
    }

    String getTimeLabel(DateTime timestamp) {
      return DateFormat('HH:mm').format(timestamp);
    }

    return CustomCard(
      height: 160,
      alignment: Alignment.center,
      backgroundColor: color,
      borderRadius: 10,
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : record == null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: FontUtils.style(
                            size: FontSize.md,
                            weight: FontWeightType.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(icon, color: Colors.white, size: 24),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withOpacity(0.5),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.noDataYet,
                            style: FontUtils.style(
                              size: FontSize.sm,
                              weight: FontWeightType.medium,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: FontUtils.style(
                            size: FontSize.md,
                            weight: FontWeightType.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(icon, color: Colors.white, size: 24),
                      ],
                    ),
                    Text(
                      DateFormat('d MMM yyyy').format(record.timeStamp),
                      style: FontUtils.style(
                        size: FontSize.xs,
                        weight: FontWeightType.medium,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          record.glucoseLevel.toStringAsFixed(0),
                          style: FontUtils.style(
                            size: FontSize.xl,
                            weight: FontWeightType.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            AppLocalizations.of(context)!.mgDl,
                            style: FontUtils.style(
                              size: FontSize.sm,
                              weight: FontWeightType.semibold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${getConditionLabel(record.condition)} ${AppLocalizations.of(context)!.at} ${getTimeLabel(record.timeStamp)}',
                      style: FontUtils.style(
                        size: FontSize.xs,
                        weight: FontWeightType.medium,
                        color: Colors.white70,
                      ),
          ),
        ],
      ),
    );
  }
}