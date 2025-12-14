import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';
import 'package:glucotrack_app/Widget/post_composser.dart';
import 'package:glucotrack_app/services/social_services/post_media_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/Widget/ContentCard.dart';
import 'package:glucotrack_app/Widget/ContentList.dart';

class PublicFeedPage extends StatefulWidget {
  final bool isInsideSocialPage;
  final String searchQuery;

  const PublicFeedPage({
    super.key,
    this.isInsideSocialPage = false,
    this.searchQuery = '',
  });

  @override
  State<PublicFeedPage> createState() => _PublicFeedPageState();
}

class _PublicFeedPageState extends State<PublicFeedPage> {
  final _svc = PostService();
  final _posts = <Map<String, dynamic>>[];
  final _filteredPosts = <Map<String, dynamic>>[];
  Map<String, List<Map<String, dynamic>>> _mediaMap = {};
  Map<String, Map<String, dynamic>> _profiles = {};
  final Set<String> _following = <String>{};
  String? _currentUserId;
  bool _loading = false;
  bool _end = false;
  int _page = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setLightStatusBar();
    _currentUserId = _svc.getCurrentUserId();
    _load(reset: true);
  }

  @override
  void didUpdateWidget(PublicFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterPosts(widget.searchQuery);
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (reset) {
        _posts.clear();
        _filteredPosts.clear();
        _profiles = {};
        _mediaMap = {};
        _end = false;
        _page = 0;
      }
      final from = _page * _pageSize;
      final to = from + _pageSize - 1;

      final rows = await _svc.loadPublicFeed(from: from, to: to);

      final ids = rows.map((r) => r['author_id'] as String).toSet().toList();
      final missing = ids.where((id) => !_profiles.containsKey(id)).toList();
      if (missing.isNotEmpty) {
        final fetched = await _svc.fetchProfilesByIds(missing);
        _profiles.addAll(fetched);
      }

      final postIds = rows.map((r) => r['id'] as String).toList();
      final media = await _svc.fetchMediaForPosts(postIds);

      print('DEBUG: Found ${media.length} posts with media');
      media.forEach((postId, items) {
        print('DEBUG: Post $postId has ${items.length} media items');
        for (var item in items) {
          print(
              'DEBUG: Media item: ${item['storage_path']} (${item['mime_type']})');
        }
      });

      final mediaSvc = PostMediaService();
      final mapped = <String, List<Map<String, dynamic>>>{};
      media.forEach((pid, items) {
        mapped[pid] = items.map((m) {
          final path = m['storage_path'] as String?;
          if (path == null || path.isEmpty) {
            print('DEBUG: storage_path is null or empty for media item');
            return {
              ...m,
              'url': '',
            };
          }
          final url = mediaSvc.publicUrl(path);
          print('DEBUG: Generated URL for $path: $url');
          return {
            ...m,
            'url': url,
          };
        }).toList();
      });
      _mediaMap.addAll(mapped);

      _posts.addAll(rows);
      _filterPosts(widget.searchQuery);
      if (rows.length < _pageSize) _end = true;
      _page++;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal load feed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() {
    return _load(reset: true);
  }

  void _filterPosts(String query) {
    setState(() {
      final searchQuery = query.toLowerCase();
      if (searchQuery.isEmpty) {
        _filteredPosts.clear();
        _filteredPosts.addAll(_posts);
      } else {
        _filteredPosts.clear();
        _filteredPosts.addAll(_posts.where((post) {
          final body = (post['body'] as String? ?? '').toLowerCase();
          final authorId = post['author_id'] as String;
          final profile = _profiles[authorId];
          final username =
              (profile?['username'] as String? ?? '').toLowerCase();
          return body.contains(searchQuery) || username.contains(searchQuery);
        }));
      }
    });
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          // Posts List
          Expanded(
            child: ContentList<Map<String, dynamic>>(
              items: [{'isComposer': true}, ..._filteredPosts, if (!_end && widget.searchQuery.isEmpty) {'isLoader': true}],
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              onRefresh: _refresh,
              itemBuilder: (context, item, index) {
                // Post Composer at first position
                if (item['isComposer'] == true) {
                  return PostComposer(onPosted: () => _refresh());
                }

                // Loader at last position
                if (item['isLoader'] == true) {
                  _load();
                  return const SizedBox.shrink();
                }

                final p = item;
                final authorId = p['author_id'] as String;
                final profile = _profiles[authorId];
                final username = (profile?['username'] as String?) ?? 'User';
                final avatarUrl = profile?['avatar_url'] as String?;
                final body = (p['body'] as String?) ?? '';
                final postId = p['id'] as String;
                final medias = _mediaMap[postId] ?? const [];
                final createdAt =
                    DateTime.tryParse(p['created_at'] as String? ?? '') ??
                        DateTime.now();

                final isOwnPost =
                    _currentUserId != null && _currentUserId == authorId;

                print(
                    'DEBUG: Rendering post $postId with ${medias.length} media items');
                if (medias.isNotEmpty) {
                  print(
                      'DEBUG: Media URLs: ${medias.map((m) => m['url']).toList()}');
                }

                return ContentCard(
                  margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  backgroundColor: const Color(0xFFFCFCFC),
                  headerAvatar: _Avatar(avatarUrl: avatarUrl, username: username),
                  headerTitle: username,
                  headerSubtitle: _formatTimestamp(createdAt),
                  headerTrailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Follow Button (only if not own post)
                      if (!isOwnPost) ...[
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              if (_following.contains(authorId)) {
                                _following.remove(authorId);
                              } else {
                                _following.add(authorId);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _following.contains(authorId)
                                  ? const Color(0xFFD9D9D9)
                                  : const Color(0xFFD4E2EF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _following.contains(authorId)
                                  ? 'Following'
                                  : 'Follow',
                              style: const TextStyle(
                                color: Color(0xFF000000),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Menu
                      Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                  customContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Body text
                      if (body.isNotEmpty) ...[
                        Text(
                          body,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Media Grid
                      if (medias.isNotEmpty) ...[
                        _MediaGrid(medias: medias),
                        const SizedBox(height: 12),
                      ],
                      // Like and Comment section
                      Row(
                        children: [
                          // Like button
                          InkWell(
                            onTap: () {
                              // Implement like functionality
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.grey.shade700,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '44',
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
                          // Comment button
                          InkWell(
                            onTap: () {
                              // Implement comment functionality
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
                                  '19',
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, required this.username});
  final String? avatarUrl;
  final String username;

  @override
  Widget build(BuildContext context) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: 22,
      backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
          ? NetworkImage(avatarUrl!)
          : null,
      child: (avatarUrl == null || avatarUrl!.isEmpty)
          ? Text(initial, style: const TextStyle(fontWeight: FontWeight.bold))
          : null,
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
    print(
        'DEBUG: _MediaGrid build called with ${widget.medias.length} media items');

    final imgs = widget.medias
        .where((m) => ((m['mime_type'] as String?) ?? '').startsWith('image/'))
        .toList();

    print('DEBUG: Filtered to ${imgs.length} image items');
    if (imgs.isEmpty) {
      print('DEBUG: No images found, returning empty widget');
      return const SizedBox.shrink();
    }

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

                    print('DEBUG: Trying to load image URL: $url');

                    if (url == null || url.isEmpty) {
                      print('DEBUG: URL is null or empty');
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
                        print('DEBUG: Image loading error: $error');
                        return Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image),
                              const SizedBox(height: 4),
                              Text(
                                'Error loading image',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                // Indicator dots (hanya tampil jika lebih dari 1 gambar)
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
