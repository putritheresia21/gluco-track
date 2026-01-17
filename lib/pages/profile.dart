import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/User_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glucotrack_app/pages/login_page.dart';
import 'package:glucotrack_app/pages/edit_profile_page.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';
import 'package:glucotrack_app/pages/Gamification/gamification_main_page.dart';
import 'package:glucotrack_app/Widget/CustomCard.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';
import 'package:glucotrack_app/services/GlucoseRepository.dart';
import 'package:glucotrack_app/models/GlucoseRecord.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/User_service.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';
import 'package:glucotrack_app/pages/SocialMedia/LikedPostsPage.dart';
import 'package:glucotrack_app/pages/SocialMedia/CommentedPostsPage.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';
import 'package:glucotrack_app/pages/SocialMedia/UserListPage.dart';
import 'package:glucotrack_app/pages/ReportsPage.dart';


//Semangat cukurukuuukkkk

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService authService = AuthService();
  final UserService _userService = UserService();
  final _gamification = GamificationService.instance;
  final _glucoseRepository = Glucoserepository();
  final PostService _postService = PostService();
  
  String username = 'Loading...';
  String? avatarUrl;
  int? age;
  bool loadingUsername = true;
  bool loadingGamification = true;
  bool loadingGlucoseStats = true;
  bool loadingSocialStats = true;
  Glucoserecord? lowestRecord;
  Glucoserecord? highestRecord;
  int _followerCount = 0;
  int _followingCount = 0;

  // Gamification Data
  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> _missionHistory = [];
  bool _loadingLeaderboard = true;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setDarkStatusBar();
    loadUsername();
    _initializeGamification();
    _loadGlucoseStats();
    _loadSocialStats();
    _loadLeaderboard();
    _loadMissionHistory();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final data = await _gamification.getLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = data;
          _loadingLeaderboard = false;
        });
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      if (mounted) setState(() => _loadingLeaderboard = false);
    }
  }

  Future<void> _loadMissionHistory() async {
    try {
      final data = await _gamification.getMissionHistory();
      if (mounted) {
        setState(() {
          _missionHistory = data;
          _loadingHistory = false;
        });
      }
    } catch (e) {
      print('Error loading history: $e');
      if (mounted) setState(() => _loadingHistory = false);
    }
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

  Future<void> loadUsername() async {
    try {
      final data = await authService.getMyProfile();
      if (!mounted) return;
      
      // Calculate age from birth_date
      int? calculatedAge;
      if (data?['birth_date'] != null) {
        try {
          final birthDate = DateTime.parse(data!['birth_date']);
          final now = DateTime.now();
          calculatedAge = now.year - birthDate.year;
          if (now.month < birthDate.month || 
              (now.month == birthDate.month && now.day < birthDate.day)) {
            calculatedAge--;
          }
        } catch (e) {
          print('Error parsing birth_date: $e');
        }
      }
      
      setState(() {
        username = data?['username'] ?? 'User';
        avatarUrl = data?['avatar_url'];
        age = calculatedAge;
        loadingUsername = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        username = 'User';
        avatarUrl = null;
        age = null;
        loadingUsername = false;
      });
    }
  }

  Future<void> _loadSocialStats() async {
    try {
      final currentUserId = _postService.getCurrentUserId();
      if (currentUserId == null) {
        if (mounted) setState(() => loadingSocialStats = false);
        return;
      }

      final followerCount = await _postService.getFollowerCount(currentUserId);
      final followingCount = await _postService.getFollowingCount(currentUserId);

      if (mounted) {
        setState(() {
          _followerCount = followerCount;
          _followingCount = followingCount;
          loadingSocialStats = false;
        });
      }
    } catch (e) {
      print('Error loading social stats: $e');
      if (mounted) {
        setState(() => loadingSocialStats = false);
      }
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
          title: Text(AppLocalizations.of(context)!.logoutConfirm),
          content: Text(AppLocalizations.of(context)!.logoutMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                logout(context);
              },
              child: Text(AppLocalizations.of(context)!.logout),
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

    return AppLayout(
      showHeader: false,
      bodyBackgroundColor: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: Column(
          children: [
            // Fixed Header (tidak scroll)
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 43,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: (!loadingUsername &&
                                avatarUrl != null &&
                                avatarUrl!.isNotEmpty)
                            ? NetworkImage(avatarUrl!)
                            : null,
                        child: loadingUsername
                            ? const CircularProgressIndicator()
                            : (avatarUrl == null || avatarUrl!.isEmpty)
                                ? Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C7796),
                                    ),
                                  )
                                : null,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loadingUsername ? '...' : username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (age != null)
                            Text(
                              AppLocalizations.of(context)!.yearsOld(age!),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 5),
                          // Badge
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
                                const SizedBox(width: 8),
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
                  ),
                ),
                Positioned(
                  top: 155,
                  left: 50, // More compact width
                  right: 50,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 5), // Minimal vertical padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Slightly smaller radius
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
                        InkWell(
                          onTap: () {
                            final userId = _postService.getCurrentUserId();
                            if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserListPage(
                                    title: 'Followers',
                                    initialCount: _followerCount,
                                    loadUsers: () => _postService.getFollowers(userId),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please wait, loading profile...')),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _InfoColumn(
                                value: loadingSocialStats
                                    ? '...'
                                    : _followerCount.toString(),
                                label: 'Followers'),
                          ),
                        ),
                        _DividerLine(),
                        InkWell(
                          onTap: () {
                            final userId = _postService.getCurrentUserId();
                            if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserListPage(
                                    title: 'Following',
                                    initialCount: _followingCount,
                                    loadUsers: () => _postService.getUsersFollowing(userId),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please wait, loading profile...')),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _InfoColumn(
                                value: loadingSocialStats
                                    ? '...'
                                    : _followingCount.toString(),
                                label: 'Following'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Lowest & Highest Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          const SizedBox(width: 14),
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
                    ),
                    const SizedBox(height: 20),

                    // Social Activity Section  
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LikedPostsPage(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite, color: Color(0xFFE63946), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Liked Posts',
                                    style: TextStyle(
                                      color: Color(0xFF003049),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CommentedPostsPage(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.comment, color: Color(0xFF2D5F8D), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Commented',
                                    style: TextStyle(
                                      color: Color(0xFF003049),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                     const SizedBox(height: 20),

                    // ================= MISSION HISTORY =================

                    const SizedBox(height: 20),

                    // ================= MISSION HISTORY =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mission History',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                   Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const GamificationMainPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.viewAll,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _loadingHistory
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : _missionHistory.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(30),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Icon(Icons.history_toggle_off,
                                                  size: 40,
                                                  color: Colors.grey.shade300),
                                              const SizedBox(height: 10),
                                              Text(
                                                'No history yet',
                                                style: TextStyle(
                                                    color: Colors.grey.shade500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        children: _missionHistory
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final history = entry.value;
                                          final points = history['points'];
                                          final task = history['user_tasks'];
                                          final title = task != null
                                              ? task['title']
                                              : 'Unknown Mission';
                                          final dateStr = history['claimed_at'];
                                          final date = dateStr != null
                                              ? DateTime.parse(dateStr)
                                              : DateTime.now();
                                          final formattedDate =
                                              DateFormat('dd MMM HH:mm')
                                                  .format(date.toLocal());

                                          return Column(
                                            children: [
                                              ListTile(
                                                leading: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.check,
                                                      color: Colors.green,
                                                      size: 20),
                                                ),
                                                title: Text(
                                                  title,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                                subtitle: Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 12),
                                                ),
                                                trailing: Text(
                                                  '+$points pts',
                                                  style: const TextStyle(
                                                    color: Color(0xFF7CB342),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (index < _missionHistory.length - 1)
                                                Divider(
                                                    height: 1,
                                                    color: Colors.grey.shade100),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

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
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            // Refresh profile after edit
                            if (result == true) {
                              loadUsername();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.editProfile,
                                  style: const TextStyle(
                                    color: Color(0xFF003049),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward,
                                    color: Color(0xFF003049)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // My Reports Button
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
                                builder: (context) => const ReportsPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.assessment, color: Color(0xFF2C7796)),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'My Reports',
                                      style: TextStyle(
                                        color: Color(0xFF003049),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward,
                                    color: Color(0xFF003049)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Glucose Reminders Button

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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.logout,
                                  style: const TextStyle(
                                    color: Color(0xFF003049),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward,
                                    color: Color(0xFF003049)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
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
                      getConditionLabel(record.condition),
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
