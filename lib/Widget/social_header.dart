import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/auth_service.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';

class SocialHeader extends StatefulWidget {
  final String currentPage; // 'feed' atau 'news'
  final VoidCallback? onNewsPressed;
  final VoidCallback? onFeedPressed;
  final Function(String)? onSearchChanged;

  const SocialHeader({
    super.key,
    required this.currentPage,
    this.onNewsPressed,
    this.onFeedPressed,
    this.onSearchChanged,
  });

  @override
  State<SocialHeader> createState() => _SocialHeaderState();
}

class _SocialHeaderState extends State<SocialHeader> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final _gamification = GamificationService.instance;

  Map<String, dynamic>? _currentUserProfile;
  bool _isLoadingProfile = true;
  bool _isLoadingGamification = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initializeGamification();
  }

  Future<void> _initializeGamification() async {
    await _gamification.initialize();
    if (mounted) {
      setState(() {
        _isLoadingGamification = false;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getMyProfile();
      setState(() {
        _currentUserProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final words = fullName.trim().split(' ');
    return words.first;
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

  @override
  Widget build(BuildContext context) {
    final currentUsername =
        _currentUserProfile?['username'] as String? ?? 'User';
    final currentAvatarUrl = _currentUserProfile?['avatar_url'] as String?;
    final firstName = _getFirstName(currentUsername);

    final currentBadge = _isLoadingGamification
        ? BadgeLevel.bronze
        : _gamification.getCurrentBadge();

    return Container(
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 30,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        children: [
          // Top Section: Avatar, Greeting, Badge, Search
          Row(
            children: [
              // Avatar
              _isLoadingProfile
                  ? const CircleAvatar(
                      radius: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : CircleAvatar(
                      radius: 28,
                      backgroundImage: (currentAvatarUrl != null &&
                              currentAvatarUrl.isNotEmpty)
                          ? NetworkImage(currentAvatarUrl)
                          : null,
                      child:
                          (currentAvatarUrl == null || currentAvatarUrl.isEmpty)
                              ? Text(
                                  firstName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                )
                              : null,
                    ),
              const SizedBox(width: 12),
              // Greeting Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What\'s up, $firstName!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Have anything to share?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                      _isLoadingGamification
                          ? Icons.workspace_premium
                          : _getBadgeIcon(currentBadge),
                      color: _isLoadingGamification
                          ? Colors.grey
                          : _getBadgeColor(currentBadge),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isLoadingGamification
                          ? '...'
                          : currentBadge
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                      style: TextStyle(
                        color: _isLoadingGamification
                            ? Colors.grey
                            : _getBadgeColor(currentBadge),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Search Icon
              InkWell(
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      if (widget.onSearchChanged != null) {
                        widget.onSearchChanged!('');
                      }
                    }
                  });
                },
                child: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  size: 28,
                ),
              ),
            ],
          ),
          // Search Bar (conditional)
          if (_isSearching) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                if (widget.onSearchChanged != null) {
                  widget.onSearchChanged!(value);
                }
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Tab Buttons: For you | News
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // For you button
              InkWell(
                onTap: widget.onFeedPressed,
                child: Text(
                  'For you',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: widget.currentPage == 'feed'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    decoration: widget.currentPage == 'feed'
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationThickness: 2,
                    color: widget.currentPage == 'feed'
                        ? Colors.black
                        : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // News button
              InkWell(
                onTap: widget.onNewsPressed,
                child: Text(
                  'News',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: widget.currentPage == 'news'
                        ? FontWeight.bold
                        : FontWeight.normal,
                    decoration: widget.currentPage == 'news'
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationThickness: 2,
                    color: widget.currentPage == 'news'
                        ? Colors.black
                        : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
