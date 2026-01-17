import 'package:flutter/material.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/badge_widget.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';
import 'package:glucotrack_app/pages/Gamification/all_badges_page.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_repository.dart';
import 'package:glucotrack_app/pages/SocialMedia/UserProfilePage.dart';

class GamificationMainPage extends StatefulWidget {
  const GamificationMainPage({super.key});

  @override
  State<GamificationMainPage> createState() => _GamificationMainPageState();
}

class _GamificationMainPageState extends State<GamificationMainPage>
    with SingleTickerProviderStateMixin {
  final _gamification = GamificationService.instance;
  late TabController _tabController;
  bool _loading = true;
  
  // Leaderboard State
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loadingLeaderboard = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialize();
    _loadLeaderboard();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _gamification.initialize(context: context);
    if (mounted) {
      setState(() => _loading = false);
    }
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

  Widget _buildMissionTab(List<MainTask> sortedTasks, int totalPoints, BadgeLevel currentBadge) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          BadgeWidget(
            level: currentBadge,
            currentPoints: totalPoints,
            showProgress: true,
            size: 100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllBadgesPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2C7796).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C7796).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2C7796),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.optionalTaskInfo,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1565C0),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              return TaskCardWidget(
                task: sortedTasks[index],
                onSeeDetail: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TaskDetailPage(task: sortedTasks[index]),
                    ),
                  );
                  setState(() {});
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    if (_loadingLeaderboard) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_leaderboard.isEmpty) {
      return const Center(child: Text('No leaderboard data yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final user = _leaderboard[index];
        final profile = user['profiles'];
        final username = profile != null ? profile['username'] ?? 'User' : 'User';
        final points = user['total_points'] ?? 0;
        final avatar = profile != null ? profile['avatar_url'] : null;
        final userId = user['user_id']; // Ensure we have the user_id

        // Rank visual logic
        Color rankColor;
        if (index == 0) {
          rankColor = const Color(0xFFFFD700); // Gold
        } else if (index == 1) {
          rankColor = const Color(0xFFC0C0C0); // Silver
        } else if (index == 2) {
          rankColor = const Color(0xFFCD7F32); // Bronze
        } else {
          rankColor = Colors.grey.shade400;
        }

        return GestureDetector(
          onTap: () {
            if (userId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userId: userId,
                    username: username,
                    avatarUrl: avatar,
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: index < 3 ? [
                BoxShadow(
                  color: rankColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : null,
              border: index < 3 ? Border.all(color: rankColor, width: 2) : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 75,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: index < 3
                        ? Icon(Icons.emoji_events, color: rankColor, size: 24)
                        : Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                      child: avatar == null
                          ? const Icon(Icons.person, size: 20, color: Colors.grey)
                          : null,
                    ),
                  ],
                ),
              ),
              title: Text(
                username,
                style: TextStyle(
                  fontWeight: index < 3 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$points pts',
                  style: const TextStyle(
                    color: Color(0xFF2C7796),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentBadge = _gamification.getCurrentBadge();
    final totalPoints = _gamification.getTotalPoints();
    final tasks = _gamification.getTasks();
    
    final sortedTasks = List<MainTask>.from(tasks)
      ..sort((a, b) => a.progress.compareTo(b.progress)); 

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF2C7796),
            leading: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                AppLocalizations.of(context)!.yourMissions,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Custom Styled TabBar in Body
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                color: const Color(0xFF2C7796),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: const [
                Tab(height: 54, text: 'Missions'),
                Tab(height: 54, text: 'Leaderboard'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await _initialize();
                    setState(() {});
                  },
                  child: _buildMissionTab(sortedTasks, totalPoints, currentBadge),
                ),
                RefreshIndicator(
                  onRefresh: () async {
                    await _loadLeaderboard();
                  },
                  child: _buildLeaderboardTab(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
