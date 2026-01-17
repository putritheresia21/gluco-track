import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';
import 'package:glucotrack_app/Widget/ContentList.dart';
import 'package:glucotrack_app/Widget/ContentCard.dart';
import 'package:glucotrack_app/pages/SocialMedia/AddPostPage.dart';
import 'package:intl/intl.dart';

class LikedPostsPage extends StatefulWidget {
  const LikedPostsPage({super.key});

  @override
  State<LikedPostsPage> createState() => _LikedPostsPageState();
}

class _LikedPostsPageState extends State<LikedPostsPage> {
  final PostService _svc = PostService();
  final List<Map<String, dynamic>> _posts = [];
  bool _loading = false;
  bool _end = false;
  int _page = 0;
  final int _pageSize = 20;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _svc.getCurrentUserId();
    _load(reset: true);
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

      final rows = await _svc.loadLikedPosts(from: from, to: to);

      _posts.addAll(rows);

      if (rows.length < _pageSize) _end = true;
      _page++;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load liked posts: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await _load(reset: true);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Posts'),
        backgroundColor: const Color(0xFF2D5F8D),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ContentList<Map<String, dynamic>>(
        items: [
          ..._posts,
          if (!_end) {'isLoader': true}
        ],
        padding: const EdgeInsets.only(bottom: 24, top: 14),
        onRefresh: _refresh,
        itemBuilder: (context, item, index) {
          if (item['isLoader'] == true) {
            _load();
            return const SizedBox.shrink();
          }

          final p = item;
          final author = p['author'] as Map<String, dynamic>?;
          final username = author?['username'] ?? 'Unknown';
          final avatarUrl = author?['avatar_url'];
          final body = p['body'] as String? ?? '';
          final postId = p['id'] as String;
          final timestamp = DateTime.tryParse(p['created_at'] as String? ?? '') ?? DateTime.now();
          final images = (p['images'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final likeCount = p['like_count'] as int? ?? 0;
          final commentCount = p['comment_count'] as int? ?? 0;

          return ContentCard(
            headerAvatar: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            headerTitle: username,
            headerSubtitle: _formatTimestamp(timestamp),
            customContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (body.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      body,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                if (images.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, i) {
                      final url = images[i]['url'] as String?;
                      if (url == null || url.isEmpty) return const SizedBox.shrink();
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 4),
                    Text('$likeCount'),
                    const SizedBox(width: 20),
                    Icon(Icons.comment, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text('$commentCount'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
