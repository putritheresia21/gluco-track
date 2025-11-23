import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialHeader extends StatefulWidget {
  final String currentPage; // 'feed' atau 'news'
  final VoidCallback? onNewsPressed;
  final VoidCallback? onFeedPressed;
  final Function(String)? onSearchChanged;
  final Map<String, Map<String, dynamic>> profiles;

  const SocialHeader({
    super.key,
    required this.currentPage,
    this.onNewsPressed,
    this.onFeedPressed,
    this.onSearchChanged,
    required this.profiles,
  });

  @override
  State<SocialHeader> createState() => _SocialHeaderState();
}

class _SocialHeaderState extends State<SocialHeader> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final currentUserId = currentUser?.id;
    final currentUserProfile =
        currentUserId != null ? widget.profiles[currentUserId] : null;
    final currentUsername =
        currentUserProfile?['username'] as String? ?? 'User';
    final currentAvatarUrl = currentUserProfile?['avatar_url'] as String?;
    final firstName = _getFirstName(currentUsername);

    return Container(
      color: const Color(0xFFE9F0F2),
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
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty)
                        ? NetworkImage(currentAvatarUrl)
                        : null,
                child: (currentAvatarUrl == null || currentAvatarUrl.isEmpty)
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
              // Gold Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Gold',
                  style: TextStyle(
                    color: Color(0xFFD4A017),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
