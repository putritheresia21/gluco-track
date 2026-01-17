import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/social_services/post_media_service.dart';
import 'package:glucotrack_app/Widget/status_bar_helper.dart';
import 'package:glucotrack_app/Widget/ContentCard.dart';
import 'package:glucotrack_app/Widget/ContentList.dart';
import 'package:glucotrack_app/pages/SocialMedia/AddPostPage.dart';
import 'package:glucotrack_app/pages/SocialMedia/UserProfilePage.dart';

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

enum FeedType { all, following, myPosts }

class _PublicFeedPageState extends State<PublicFeedPage> 
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _svc = PostService();
  final _posts = <Map<String, dynamic>>[];
  final _filteredPosts = <Map<String, dynamic>>[];
  final Set<String> _following = <String>{};
  String? _currentUserId;
  bool _loading = false;
  bool _end = false;
  int _page = 0;
  final int _pageSize = 20;
  FeedType _currentFeedType = FeedType.all;
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true; // Keep state alive when switching tabs

  @override
  void initState() {
    super.initState();
    StatusBarHelper.setLightStatusBar();
    _currentUserId = _svc.getCurrentUserId();
    _tabController = TabController(length: 3, vsync: this); // Changed from 2 to 3
    _tabController.addListener(_onTabChanged);
    _load(reset: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentFeedType = FeedType.values[_tabController.index];
      });
      _load(reset: true);
    }
  }

  @override
  void didUpdateWidget(PublicFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterPosts(widget.searchQuery);
    }
  }

  // Removed reassemble auto-reload for better performance
  // User can pull-to-refresh if they want fresh data


  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (reset) {
        _posts.clear();
        _filteredPosts.clear();
        _end = false;
        _page = 0;
      }
      final from = _page * _pageSize;
      final to = from + _pageSize - 1;

      // Load based on feed type
      List<Map<String, dynamic>> rows;
      if (_currentFeedType == FeedType.all) {
        rows = await _svc.loadPublicFeed(from: from, to: to);
      } else if (_currentFeedType == FeedType.following) {
        rows = await _svc.loadFollowingFeed(from: from, to: to);
      } else {
        // My Posts
        rows = await _svc.loadMyPosts(from: from, to: to);
      }

      _posts.addAll(rows);
      
      // TODO: Optimize this - loading following status one by one is too slow
      // Temporarily disabled for better performance
      /* 
      // Load following status for all authors in this batch
      final authorIds = rows
          .map((post) => post['author_id'] as String?)
          .where((id) => id != null && id != _currentUserId)
          .cast<String>()
          .toSet();
      
      for (final authorId in authorIds) {
        try {
          final isFollowing = await _svc.isFollowing(authorId);
          if (isFollowing) {
            _following.add(authorId);
          }
        } catch (e) {
          print('Error checking following status for $authorId: $e');
        }
      }
      */
      
      _filterPosts(widget.searchQuery);
      
      if (rows.length < _pageSize) _end = true;
      _page++;
    } catch (e) {
      print('ERROR _load: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadFeed(e.toString()))));
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
          final author = post['author'] as Map<String, dynamic>?;
          final username = (author?['username'] as String? ?? '').toLowerCase();
          return body.contains(searchQuery) || username.contains(searchQuery);
        }));
      }
    });
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

  void _showCommentSheet(String postId, {String? replyToCommentId, VoidCallback? onCommentAdded}) {
    final commentController = TextEditingController();
    String? replyingToId;
    String? replyingToUsername;
    final refreshNotifier = ValueNotifier<int>(0); // For triggering refresh
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Comments List
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: refreshNotifier,
                    builder: (context, _, __) => FutureBuilder<List<Map<String, dynamic>>>(
                      future: _svc.getComments(postId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        
                        final comments = snapshot.data ?? [];
                        
                        if (comments.isEmpty) {
                          return const Center(
                            child: Text('No comments yet. Be the first to comment!'),
                          );
                        }
                        
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return _CommentItem(
                              comment: comments[index],
                              postId: postId,
                              currentUserId: _currentUserId,
                              onDelete: () {
                                refreshNotifier.value++;
                              },
                              onReply: (commentId, username) {
                                setModalState(() {
                                  replyingToId = commentId;
                                  replyingToUsername = username;
                                });
                                commentController.clear();
                              },
                              formatTimestamp: _formatTimestamp,
                              svc: _svc,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // Replying indicator
                if (replyingToId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.reply, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Replying to $replyingToUsername',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setModalState(() {
                              replyingToId = null;
                              replyingToUsername = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                // Comment Input
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: replyingToId != null 
                                ? 'Write a reply...' 
                                : 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF2D5F8D)),
                        onPressed: () async {
                          if (commentController.text.trim().isEmpty) return;
                          
                          try {
                            await _svc.addComment(
                              postId: postId,
                              text: commentController.text.trim(),
                              parentCommentId: replyingToId,
                            );
                            commentController.clear();
                            setModalState(() {
                              replyingToId = null;
                              replyingToUsername = null;
                            });
                            // Trigger refresh
                            refreshNotifier.value++;
                            // Notify feed to update comment count
                            onCommentAdded?.call();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to add comment: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPostPage()),
    );
    if (result == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          // Feed Type Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2D5F8D),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2D5F8D),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Following'),
                Tab(text: 'My Posts'),
              ],
            ),
          ),
          // Posts List
          Expanded(
            child: ContentList<Map<String, dynamic>>(
              items: [
                ..._filteredPosts,
                if (!_end && widget.searchQuery.isEmpty) {'isLoader': true}
              ],
              padding: const EdgeInsets.only(bottom: 24, top: 14),
              onRefresh: _refresh,
              itemBuilder: (context, item, index) {
                // Loader at last position
                if (item['isLoader'] == true) {
                  _load();
                  return const SizedBox.shrink();
                }

                final p = item;
                final authorId = p['author_id'] as String;
                final author = p['author'] as Map<String, dynamic>?;
                final username = (author?['username'] as String?) ?? 'User';
                final avatarUrl = author?['avatar_url'] as String?;
                final body = (p['body'] as String?) ?? '';
                final postId = p['id'] as String;
                final medias = (p['images'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? const [];
                final createdAt =
                    DateTime.tryParse(p['created_at'] as String? ?? '') ??
                        DateTime.now();

                final isOwnPost =
                    _currentUserId != null && _currentUserId == authorId;

                // Get like and comment data
                final likeCount = p['like_count'] as int? ?? 0;
                final commentCount = p['comment_count'] as int? ?? 0;
                final isLiked = p['is_liked'] as bool? ?? false;

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
                  onHeaderTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          userId: authorId,
                          username: username,
                          avatarUrl: avatarUrl,
                        ),
                      ),
                    );
                  },
                  headerTrailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Follow Button (only if not own post)
                      if (!isOwnPost) ...[
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            final savedContext = context;
                            final wasFollowing = _following.contains(authorId);
                            
                            // Show confirmation dialog for unfollow
                            if (wasFollowing) {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text(
                                      'Unfollow $username?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to stop following this user?',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(false),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.grey[600],
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        ),
                                        child: const Text(
                                          'Unfollow',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              
                              // If user cancelled, don't proceed
                              if (confirmed != true) return;
                            }
                            
                            // Optimistic update
                            setState(() {
                              if (wasFollowing) {
                                _following.remove(authorId);
                              } else {
                                _following.add(authorId);
                              }
                            });

                            try {
                              // Actual network call
                              if (wasFollowing) {
                                await _svc.unfollowUser(authorId);
                              } else {
                                await _svc.followUser(authorId);
                              }
                            } catch (e) {
                              // Revert on error
                              if (mounted) {
                                setState(() {
                                  if (wasFollowing) {
                                    _following.add(authorId);
                                  } else {
                                    _following.remove(authorId);
                                  }
                                });
                              }
                              
                              if (mounted) {
                                try {
                                  ScaffoldMessenger.of(savedContext).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                } catch (_) {
                                  // Widget is disposed, ignore
                                }
                              }
                            }
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
                        const SizedBox(width: 8),
                      ],
                      // Delete button for My Posts, menu icon for others
                      if (_currentFeedType == FeedType.myPosts && isOwnPost)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade400,
                          ),
                          onPressed: () async {
                            // Show confirmation dialog
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: const Text(
                                  'Delete Post?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this post? This action cannot be undone.',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, false),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey[600],
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(dialogContext, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              try {
                                await _svc.deletePost(postId);
                                if (mounted) {
                                  setState(() {
                                    _posts.removeWhere((p) => p['id'] == postId);
                                    _filteredPosts.removeWhere((p) => p['id'] == postId);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Post deleted successfully')),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete post: $e')),
                                  );
                                }
                              }
                            }
                          },
                        )
                      else
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
                            onTap: () async {
                              try {
                                // Optimistic update
                                setState(() {
                                  p['is_liked'] = !isLiked;
                                  p['like_count'] = isLiked ? likeCount - 1 : likeCount + 1;
                                });

                                // Send to server
                                if (isLiked) {
                                  await _svc.unlikePost(postId);
                                } else {
                                  await _svc.likePost(postId);
                                }
                              } catch (e) {
                                // Revert on error
                                setState(() {
                                  p['is_liked'] = isLiked;
                                  p['like_count'] = likeCount;
                                });
                                print('Error toggling like: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update like: $e')),
                                  );
                                }
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
                          // Comment button
                          InkWell(
                            onTap: () {
                              _showCommentSheet(
                                postId,
                                onCommentAdded: () {
                                  // Update comment count optimistically
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPost,
        backgroundColor: const Color(0xFF2D5F8D),
        child: const Icon(Icons.edit, color: Colors.white),
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

  void _openFullscreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenImageViewer(
          images: widget.medias
              .where((m) =>
                  ((m['mime_type'] as String?) ?? '').startsWith('image/'))
              .toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'DEBUG: _MediaGrid build called with ${widget.medias.length} media items');

    final imgs = widget.medias
        .where((m) => ((m['mime_type'] as String?) ?? '').startsWith('image/'))
        .toList();


    if (imgs.isEmpty) {

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



                    if (url == null || url.isEmpty) {

                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image),
                      );
                    }

                    return GestureDetector(
                      onTap: () => _openFullscreenImage(context, i),
                      child: Image.network(
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image),
                                const SizedBox(height: 4),
                                Text(
                                  'Error loading image',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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

class _FullscreenImageViewer extends StatefulWidget {
  const _FullscreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<Map<String, dynamic>> images;
  final int initialIndex;

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.images[index]['url'] as String?;
              if (url == null || url.isEmpty) {
                return const Center(
                  child: Icon(Icons.broken_image, color: Colors.white),
                );
              }
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  if (widget.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${widget.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.postId,
    required this.currentUserId,
    required this.onDelete,
    required this.onReply,
    required this.formatTimestamp,
    required this.svc,
    this.isReply = false,
  });

  final Map<String, dynamic> comment;
  final String postId;
  final String? currentUserId;
  final VoidCallback onDelete;
  final Function(String commentId, String username) onReply;
  final String Function(DateTime) formatTimestamp;
  final PostService svc;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final author = comment['author'] as Map<String, dynamic>?;
    final username = author?['username'] ?? 'User';
    final avatarUrl = author?['avatar_url'];
    final text = comment['text'] as String;
    final commentId = comment['id'] as String;
    final createdAt = DateTime.tryParse(
      comment['created_at'] as String? ?? '',
    ) ?? DateTime.now();
    final replies = (comment['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: isReply ? 48 : 0),
          child: ListTile(
            leading: CircleAvatar(
              radius: isReply ? 16 : 20,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null ? Text(username[0].toUpperCase()) : null,
            ),
            title: Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatTimestamp(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!isReply)
                      InkWell(
                        onTap: () => onReply(commentId, username),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: comment['user_id'] == currentUserId
                ? IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () async {
                      await svc.deleteComment(commentId);
                      onDelete();
                    },
                  )
                : null,
          ),
        ),
        // Render nested replies
        if (replies.isNotEmpty)
          ...replies.map((reply) => _CommentItem(
                comment: reply,
                postId: postId,
                currentUserId: currentUserId,
                onDelete: onDelete,
                onReply: onReply,
                formatTimestamp: formatTimestamp,
                svc: svc,
                isReply: true,
              )),
      ],
    );
  }
}
