import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/ReminderSettingsPage.dart';
import 'package:glucotrack_app/services/ReminderRepository.dart';
import 'package:glucotrack_app/pages/Gamification/gamification_main_page.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';
import 'package:glucotrack_app/Widget/CustomCard.dart';
import 'package:glucotrack_app/pages/NavbarItem/Navbar.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/User_service.dart';
import 'package:glucotrack_app/services/NotificationRepository.dart';
import 'package:glucotrack_app/services/NotificationService.dart';
import 'package:glucotrack_app/pages/NotificationListPage.dart';
import 'package:glucotrack_app/services/ReportService.dart';

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
  List<Glucoserecord> _allRecords = []; // Store records for chart
  
  List<GlucoseReminder> _activeReminders = [];
  bool _loadingReminders = true;
  
  // Notification Cache
  List<Map<String, dynamic>> _notifications = [];
  bool _loadingNotifications = true;

  final PageController _summaryPageController = PageController(viewportFraction: 0.9);
  Timer? _summaryTimer;
  int _currentSummaryPage = 0;

  @override
  void dispose() {
    _summaryTimer?.cancel();
    _summaryPageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _summaryTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_summaryPageController.hasClients) {
        if (_currentSummaryPage < 2) {
          _currentSummaryPage++;
        } else {
          _currentSummaryPage = 0;
        }
        _summaryPageController.animateToPage(
          _currentSummaryPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadNextReminder() async {
    try {
      final reminders = await ReminderRepository().getActiveReminders();
      if (!mounted) return;

      // Sort by time
      reminders.sort((a, b) {
        final aTime = a.reminderTime.hour * 60 + a.reminderTime.minute;
        final bTime = b.reminderTime.hour * 60 + b.reminderTime.minute;
        return aTime.compareTo(bTime);
      });

      setState(() {
        _activeReminders = reminders;
        _loadingReminders = false;
      });

    } catch (e) {
      print('Error loading reminders: $e');
      if (mounted) setState(() => _loadingReminders = false);
    }
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Glucose Reminders", // Hardcode first, or add to arb later if needed
                style: FontUtils.style(
                  size: FontSize.mdl,
                  weight: FontWeightType.bold,
                ),
              ),
              InkWell(
                onTap: () async {
                   await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReminderSettingsPage(),
                    ),
                  );
                  _loadNextReminder(); // Refresh after return
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_alarm, size: 16, color: Color(0xFF2C7796)),
                      const SizedBox(width: 6),
                      Text(
                        "Set Reminder",
                        style: FontUtils.style(
                          size: FontSize.sm,
                          weight: FontWeightType.bold,
                          color: const Color(0xFF2C7796),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_loadingReminders)
           const Center(child: CircularProgressIndicator())
        else if (_activeReminders.isEmpty)
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.grey.withOpacity(0.2)),
             ),
             child: Column(
               children: [
                 Icon(Icons.alarm_off, color: Colors.grey.withOpacity(0.5), size: 40),
                 const SizedBox(height: 8),
                 Text(
                   "No active reminders",
                   style: TextStyle(color: Colors.grey[600], fontSize: 13),
                 ),
               ],
             ),
           )
        else
           Column(
             children: _activeReminders.map((reminder) {
               return Container(
                 margin: const EdgeInsets.only(bottom: 10),
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.03),
                       offset: const Offset(0, 2),
                       blurRadius: 8,
                     ),
                   ],
                 ),
                 child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(
                         color: const Color(0xFF2C7796).withOpacity(0.1),
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.alarm, color: Color(0xFF2C7796), size: 20),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             reminder.label,
                             style: const TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 16,
                               color: Colors.black87,
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             _formatDays(reminder.daysOfWeek),
                             style: TextStyle(
                               color: Colors.grey[600],
                               fontSize: 12,
                             ),
                           ),
                         ],
                       ),
                     ),
                     Text(
                       DateFormat('HH:mm').format(DateTime(2022, 1, 1, reminder.reminderTime.hour, reminder.reminderTime.minute)),
                       style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 20,
                         color: Color(0xFF2C7796),
                       ),
                     ),
                   ],
                 ),
               );
             }).toList(),
           ),
      ],
    );
  }

  String _formatDays(List<int> days) {
    if (days.length == 7) return "Every day";
    List<String> dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    // Sort days
    days.sort();
    return days.map((d) => dayNames[d]).join(", ");
  }

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setLightStatusBar();
    
    // Critical loads
    loadProfile();
    _loadNextReminder();
    _loadGlucoseStats();
    _loadNotifications();
    
    // Lazy/Deferred loads (Run after UI render)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGamification();
      _startAutoScroll();
      
      // Delay non-essential services to prevent jank
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) NotificationService().ensureTokenSaved();
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) ReportService().autoGenerateReports();
      });
    });
  }

  Future<void> _loadNotifications() async {
    try {
      print('🔔 Loading notifications from HomePage...'); // Debug log
      final notifications = await NotificationRepository().getNotifications(limit: 3);
      print('🔔 Loaded ${notifications.length} notifications'); // Debug log

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _loadingNotifications = false;
        });
      }
    } catch (e) {
      print('❌ Error loading notifications: $e'); // Debug log
      if (mounted) setState(() => _loadingNotifications = false);
    }
  }

  Future<void> _loadGlucoseStats() async {
    try {
      final userId = _userService.currentUserId ?? 'default_user';
      final lowest = await _glucoseRepository.getLowestGlucoseRecord(userId);
      final highest = await _glucoseRepository.getHighestGlucoseRecord(userId);
      final all = await _glucoseRepository.getAllGlucoseRecords(userId);

      if (mounted) {
        // Optimization: Filter for last 30 days only for charts to save memory
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final recentRecords = all.where((r) => r.timeStamp.isAfter(thirtyDaysAgo)).toList();

        setState(() {
          lowestRecord = lowest;
          highestRecord = highest;
          _allRecords = recentRecords;
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
      actions: [
        const SizedBox(width: 8),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const SizedBox(height: 30),
                // Summary Section (Daily, Weekly, Monthly)
                if (loadingGlucoseStats)
                   const Center(child: CircularProgressIndicator())
                else
                   SizedBox(
                     height: 180,
                     child: PageView(
                       controller: _summaryPageController,
                       physics: const BouncingScrollPhysics(),
                       children: [
                         Padding(
                           padding: const EdgeInsets.only(right: 12),
                           child: _buildSummaryCard(
                             title: "Daily", // Localize later
                             records: _allRecords.where((r) {
                               final now = DateTime.now();
                               return r.timeStamp.year == now.year &&
                                      r.timeStamp.month == now.month &&
                                      r.timeStamp.day == now.day;
                             }).toList(),
                             colors: [const Color(0xFF2C7796), const Color(0xFF4592AF)], // Primary Teal Gradient
                             icon: Icons.today,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.only(right: 12),
                           child: _buildSummaryCard(
                             title: "Weekly",
                             records: _allRecords.where((r) {
                               return r.timeStamp.isAfter(DateTime.now().subtract(const Duration(days: 7)));
                             }).toList(),
                             colors: [const Color(0xFF4A90B8), const Color(0xFF69ADC9)], // Lighter Blue-Teal
                             icon: Icons.date_range,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.only(right: 12),
                           child: _buildSummaryCard(
                             title: "Monthly", // Localize later
                             records: _allRecords.where((r) {
                               return r.timeStamp.isAfter(DateTime.now().subtract(const Duration(days: 30)));
                             }).toList(),
                             colors: [const Color(0xFF1A5674), const Color(0xFF2C7796)], // Darker Teal
                             icon: Icons.calendar_month,
                           ),
                         ),
                       ],
                     ),
                   ),

                const SizedBox(height: 15),



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

                // Reminder Section
                _buildReminderSection(),

                const SizedBox(height: 25),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                  child: Text(
                    AppLocalizations.of(context)!.notifications,
                    style: FontUtils.style(
                      size: FontSize.mdl,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.last7Days,
                            style: FontUtils.style(
                              size: FontSize.md,
                              weight: FontWeightType.bold,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationListPage(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: FontUtils.style(
                                size: FontSize.sm,
                                weight: FontWeightType.semibold,
                                color: const Color(0xFFD4EAF7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Cached Notifications (Optimized)
                      if (_loadingNotifications)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      else if (_notifications.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No notifications',
                              style: FontUtils.style(
                                size: FontSize.sm,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _notifications.length,
                            separatorBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(color: Colors.white.withOpacity(0.4)),
                            ),
                            itemBuilder: (context, index) {
                              final notif = _notifications[index];
                              final actor = notif['actor'] as Map<String, dynamic>?;
                              final avatarUrl = actor?['avatar_url'] as String?;
                              final username = actor?['username'] as String? ?? 'Unknown';
                              final body = notif['body'] as String;
                              final createdAt = DateTime.parse(notif['created_at'] as String);
                              final now = DateTime.now();
                              final diff = now.difference(createdAt);
                              
                              String timeAgo;
                              if (diff.inDays > 0) {
                                timeAgo = AppLocalizations.of(context)!.daysAgo(diff.inDays);
                              } else if (diff.inHours > 0) {
                                timeAgo = AppLocalizations.of(context)!.hoursAgo(diff.inHours);
                              } else if (diff.inMinutes > 0) {
                                timeAgo = AppLocalizations.of(context)!.minsAgo(diff.inMinutes);
                              } else {
                                timeAgo = AppLocalizations.of(context)!.justNow;
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: (avatarUrl == null || avatarUrl.isEmpty)
                                        ? Text(
                                            username[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      body,
                                      style: FontUtils.style(
                                        size: FontSize.sm,
                                        weight: FontWeightType.semibold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    timeAgo,
                                    style: FontUtils.style(
                                      size: FontSize.xs,
                                      weight: FontWeightType.medium,
                                      color: const Color(0xFFD4EAF7),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

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
                          size: FontSize.mdl,
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
          backgroundColor: const Color(0xFF2C7796),
          backgroundImage: (!loadingProfile &&
                  profileImageUrl != null &&
                  profileImageUrl!.isNotEmpty)
              ? NetworkImage(profileImageUrl!)
              : null,
          child: loadingProfile
              ? const CircularProgressIndicator()
              : (profileImageUrl == null || profileImageUrl!.isEmpty)
                  ? Text(
                      (userProfile?['username'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required List<Glucoserecord> records,
    required List<Color> colors,
    required IconData icon,
  }) {
    double average = 0;
    if (records.isNotEmpty) {
      double sum = records.fold(0.0, (prev, record) => prev + record.glucoseLevel);
      average = sum / records.length;
    }

    final primaryColor = colors.first;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5, top: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${records.length} records',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                             average > 0 ? average.toStringAsFixed(0) : '-',
                             style: const TextStyle(
                               color: Colors.white,
                               fontSize: 42,
                               fontWeight: FontWeight.bold,
                               height: 1.0,
                             ),
                          ),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'mg/dL',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
  // _buildNextReminderCard method removed as it is no longer used
}