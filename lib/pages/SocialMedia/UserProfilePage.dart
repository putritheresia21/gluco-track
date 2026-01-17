import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/User_service.dart';
import 'package:glucotrack_app/Widget/ContentCard.dart';
import 'package:glucotrack_app/Widget/ContentList.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String? username;
  final String? avatarUrl;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.username,
    this.avatarUrl,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _svc = PostService();
  final _userService = UserService();
  final _posts = <Map<String, dynamic>>[];
  
  String? _currentUserId;
  bool _loading = false;
  bool _loadingProfile = true;
  bool _end = false;
  int _page = 0;
  final int _pageSize = 20;
  
  // Profile data
  String? _username;
  String? _avatarUrl;
  int? _age;
  int _followerCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = _svc.getCurrentUserId();
    _username = widget.username;
    _avatarUrl = widget.avatarUrl;
    _loadProfile();
    _loadFollowStats();
    _load(reset: true);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _userService.getUserProfile(widget.userId);
      if (profile != null && mounted) {
        // Calculate age from birth_date
        int? calculatedAge;
        if (profile.birthDate != null) {
          final now = DateTime.now();
          calculatedAge = now.year - profile.birthDate!.year;
          if (now.month < profile.birthDate!.month || 
              (now.month == profile.birthDate!.month && now.day < profile.birthDate!.day)) {
            calculatedAge--;
          }
        }
        
        setState(() {
          _username = profile.username;
          _avatarUrl = profile.avatarUrl;
          _age = calculatedAge;
          _loadingProfile = false;
        });
      } else if (mounted) {
        setState(() => _loadingProfile = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  Future<void> _loadFollowStats() async {
    try {
      final followerCount = await _svc.getFollowerCount(widget.userId);
      final followingCount = await _svc.getFollowingCount(widget.userId);
      final isFollowing = _currentUserId != null && _currentUserId != widget.userId
          ? await _svc.isFollowing(widget.userId)
          : false;
      
      if (mounted) {
        setState(() {
          _followerCount = followerCount;
          _followingCount = followingCount;
          _isFollowing = isFollowing;
        });
      }
    } catch (e) {
      print('Error loading follow stats: $e');
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (reset) {
        _posts.clear();
        _end = false;
        _page = 0;
      }
      final from = _page * _pageSize;
      final to = from + _pageSize - 1;

      final rows = await _svc.loadUserPosts(
        userId: widget.userId,
        from: from,
        to: to,
      );

      _posts.addAll(rows);
      
      if (rows.length < _pageSize) _end = true;
      _page++;
    } catch (e) {
      print('ERROR _load: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() {
    _loadFollowStats();
    return _load(reset: true);
  }

  String _formatTimestamp(DateTime dateTime) {
    if (!mounted) return '';
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minsAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  void _showCommentSheet(String postId, {VoidCallback? onCommentAdded}) {
    // Reuse the comment sheet from Feeds.dart
    // For now, we'll show a simple snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment feature - to be implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = _currentUserId == widget.userId;
    final initial = (_username ?? 'U').isNotEmpty ? (_username ?? 'U')[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C7796),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _loadingProfile ? 'Loading...' : (_username ?? 'User Profile'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            color: const Color(0xFF2C7796),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 43,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? NetworkImage(_avatarUrl!)
                            : null,
                        child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                            ? Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24))
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _loadingProfile ? '...' : (_username ?? 'User'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_age != null)
                              Text(
                                AppLocalizations.of(context)!.yearsOld(_age!),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _StatText(
                                  label: 'Followers',
                                  value: _followerCount.toString(),
                                ),
                                const SizedBox(width: 16),
                                _StatText(
                                  label: 'Following',
                                  value: _followingCount.toString(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Follow/Unfollow button (only if not own profile)
                      if (!isOwnProfile)
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            try {
                              if (_isFollowing) {
                                await _svc.unfollowUser(widget.userId);
                                setState(() {
                                  _isFollowing = false;
                                  _followerCount--;
                                });
                              } else {
                                await _svc.followUser(widget.userId);
                                setState(() {
                                  _isFollowing = true;
                                  _followerCount++;
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _isFollowing
                                  ? const Color(0xFFD9D9D9)
                                  : const Color(0xFFD4E2EF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isFollowing
                                  ? AppLocalizations.of(context)!.following
                                  : AppLocalizations.of(context)!.follow,
                              style: const TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
          // Posts Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.grid_on, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ContentList<Map<String, dynamic>>(
              items: [
                ..._posts,
                if (!_end) {'isLoader': true}
              ],
              padding: const EdgeInsets.only(bottom: 24, top: 0),
              onRefresh: _refresh,
              itemBuilder: (context, item, index) {
                // Loader at last position
                if (item['isLoader'] == true) {
                  _load();
                  return const SizedBox.shrink();
                }

                final p = item;
                final body = (p['body'] as String?) ?? '';
                final postId = p['id'] as String;
                final medias = (p['images'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? const [];
                final createdAt =
                    DateTime.tryParse(p['created_at'] as String? ?? '') ??
                        DateTime.now();

                final likeCount = p['like_count'] as int? ?? 0;
                final commentCount = p['comment_count'] as int? ?? 0;
                final isLiked = p['is_liked'] as bool? ?? false;

                return ContentCard(
                  margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  backgroundColor: const Color(0xFFFCFCFC),
                  headerTitle: _username ?? 'User',
                  headerSubtitle: _formatTimestamp(createdAt),
                  customContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (body.isNotEmpty) ...[
                        Text(
                          body,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (medias.isNotEmpty) ...[
                        _MediaGrid(medias: medias),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              try {
                                setState(() {
                                  p['is_liked'] = !isLiked;
                                  p['like_count'] = isLiked ? likeCount - 1 : likeCount + 1;
                                });

                                if (isLiked) {
                                  await _svc.unlikePost(postId);
                                } else {
                                  await _svc.likePost(postId);
                                }
                              } catch (e) {
                                setState(() {
                                  p['is_liked'] = isLiked;
                                  p['like_count'] = likeCount;
                                });
                                print('Error toggling like: $e');
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$likeCount',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          InkWell(
                            onTap: () {
                              _showCommentSheet(
                                postId,
                                onCommentAdded: () {
                                  setState(() {
                                    p['comment_count'] = (p['comment_count'] as int? ?? 0) + 1;
                                  });
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.grey.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$commentCount',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatText extends StatelessWidget {
  final String label;
  final String value;

  const _StatText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MediaGrid extends StatefulWidget {
  const _MediaGrid({required this.medias});
  final List<Map<String, dynamic>> medias;

  @override
  State<_MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<_MediaGrid> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.medias
        .where((m) => ((m['mime_type'] as String?) ?? '').startsWith('image/'))
        .toList();

    if (imgs.isEmpty) return const SizedBox.shrink();

    final count = imgs.length;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: count,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, i) {
                    final mediaItem = imgs[i];
                    final url = mediaItem['url'] as String?;

                    if (url == null || url.isEmpty) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image),
                      );
                    }

                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    );
                  },
                ),
                if (count > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        count,
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
