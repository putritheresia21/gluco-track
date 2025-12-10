import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/Widget/gamification_widget/badge_widget.dart';
import 'package:glucotrack_app/Widget/gamification_widget/task_card_widget.dart';
import 'package:glucotrack_app/pages/Gamification/task_detail_page.dart';
import 'package:glucotrack_app/pages/Gamification/all_badges_page.dart';

class GamificationMainPage extends StatefulWidget {
  const GamificationMainPage({super.key});

  @override
  State<GamificationMainPage> createState() => _GamificationMainPageState();
}

class _GamificationMainPageState extends State<GamificationMainPage> {
  final _gamification = GamificationService.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _gamification.initialize();
    if (mounted) {
      setState(() => _loading = false);
    }
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
            title: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Your Missions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
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
                    const Expanded(
                      child: Text(
                        'Task ini bersifat opsional. Selesaikan untuk mendapat reward spesial!',
                        style: TextStyle(
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
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCardWidget(
                    task: tasks[index],
                    onSeeDetail: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailPage(task: tasks[index]),
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
        ),
      ),
    );
  }
}
