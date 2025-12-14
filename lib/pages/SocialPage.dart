import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/SocialMedia/Feeds.dart';
import 'package:glucotrack_app/pages/SocialMedia/NewsPage.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _currentIndex = 0;
  String _searchQuery = '';
  
  // Header related
  final AuthService _authService = AuthService();
  final _gamification = GamificationService.instance;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _currentUserProfile;
  bool _isLoadingProfile = true;
  bool _isLoadingGamification = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initializeGamification();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getMyProfile();
      print('DEBUG social_page: Profile data = $profile');
      if (profile != null) {
        print('DEBUG social_page: username = ${profile['username']}');
        print('DEBUG social_page: Profile keys = ${profile.keys}');
      }
      if (mounted) {
        setState(() {
          _currentUserProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('DEBUG social_page: Error loading profile = $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _initializeGamification() async {
    await _gamification.initialize();
    if (mounted) {
      setState(() {
        _isLoadingGamification = false;
      });
    }
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final words = fullName.trim().split(' ');
    return words.first;
  }

  Widget _buildHeaderContent() {
    final currentUsername = _currentUserProfile?['username'] as String? ?? 'User';
    final currentAvatarUrl = _currentUserProfile?['avatar_url'] as String?;
    final firstName = _getFirstName(currentUsername);
    final currentBadge = _isLoadingGamification ? BadgeLevel.bronze : _gamification.getCurrentBadge();

    Color getBadgeColor(BadgeLevel level) {
      switch (level) {
        case BadgeLevel.bronze: return const Color(0xFFCD7F32);
        case BadgeLevel.silver: return const Color(0xFFC0C0C0);
        case BadgeLevel.gold: return const Color(0xFFFFD700);
        case BadgeLevel.platinum: return const Color(0xFFE5E4E2);
        case BadgeLevel.diamond: return const Color(0xFFB9F2FF);
      }
    }

    IconData getBadgeIcon(BadgeLevel level) {
      switch (level) {
        case BadgeLevel.bronze: return Icons.workspace_premium;
        case BadgeLevel.silver: return Icons.military_tech;
        case BadgeLevel.gold: return Icons.emoji_events;
        case BadgeLevel.platinum: return Icons.stars;
        case BadgeLevel.diamond: return Icons.diamond;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar
          _isLoadingProfile
              ? const CircleAvatar(radius: 28, child: CircularProgressIndicator(strokeWidth: 2))
              : CircleAvatar(
                  radius: 28,
                  backgroundImage: (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty)
                      ? NetworkImage(currentAvatarUrl)
                      : null,
                  child: (currentAvatarUrl == null || currentAvatarUrl.isEmpty)
                      ? Text(firstName[0].toUpperCase(), style: FontUtils.style(size: FontSize.xl, weight: FontWeightType.bold))
                      : null,
                ),
          const SizedBox(width: 12),
          // Greeting Text
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What\'s up,',
                  style: FontUtils.style(size: FontSize.lg, weight: FontWeightType.bold, color: Colors.white),
                ),
                Text(
                  '$firstName!',
                  style: FontUtils.style(size: FontSize.lg, weight: FontWeightType.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Have anything to share?',
                  style: FontUtils.style(size: FontSize.sm, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isLoadingGamification ? Icons.workspace_premium : getBadgeIcon(currentBadge),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isLoadingGamification ? '...' : currentBadge.toString().split('.').last.toUpperCase(),
                  style: FontUtils.style(
                    size: FontSize.xs,
                    weight: FontWeightType.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Search Icon
          // InkWell(
          //   onTap: () {
          //     setState(() {
          //       _isSearching = !_isSearching;
          //       if (!_isSearching) {
          //         _searchController.clear();
          //         _searchQuery = '';
          //       }
          //     });
          //   },
          //   child: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black, size: 28),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBack: false,
      showHeader: true,
      headerBottomRadius: BorderRadius.circular(0),
      headerBackgroundColor: const Color(0xFF2C7796),
      headerForegroundColor: Colors.white,
      bodyBackgroundColor: const Color(0xFFF5F5F5),
      headerContent: _buildHeaderContent(),
      headerHeight: 120,
      child: Column(
        children: [
          // Search Bar (conditional)
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF5F5F5),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search posts or users...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          // Tab Buttons: For you | News
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFFF5F5F5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => setState(() => _currentIndex = 0),
                  child: Text(
                    'For you',
                    style: FontUtils.style(
                      size: FontSize.lg,
                      weight: _currentIndex == 0 ? FontWeightType.bold : FontWeightType.regular,
                      color: _currentIndex == 0 ? Colors.black : Colors.black54,
                      decoration: _currentIndex == 0 ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                InkWell(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Text(
                    'News',
                    style: FontUtils.style(
                      size: FontSize.lg,
                      weight: _currentIndex == 1 ? FontWeightType.bold : FontWeightType.regular,
                      color: _currentIndex == 1 ? Colors.black : Colors.black54,
                      decoration: _currentIndex == 1 ? TextDecoration.underline : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey.shade300),
          // Pages stay alive (IndexedStack keeps state)
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                PublicFeedPage(
                  isInsideSocialPage: true,
                  searchQuery: _searchQuery,
                ),
                NewsPage(
                  isInsideSocialPage: true,
                  searchQuery: _searchQuery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
