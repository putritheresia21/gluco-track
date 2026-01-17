// post_service.dart
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_media_service.dart';
import '../NotificationRepository.dart';

class PostService {
  final sb = Supabase.instance.client;
  final mediaSvc = PostMediaService();
  final _notificationRepo = NotificationRepository();

  /// ====== CREATE ======

  Future<String> createPost({required String body}) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final row = await sb
        .from('posts')
        .insert({
          'author_id': user.id, // pastikan kolom DB sudah author_id
          'body': body, // dan kolom 'body'
          'visibility': 'public', // default public
        })
        .select('id')
        .single();

    return row['id'] as String;
  }

  Future<String> createPostWithImages({
    required String body,
    required List<File> files,
  }) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // 1) insert post
    final post = await sb
        .from('posts')
        .insert({
          'author_id': user.id,
          'body': body,
          'visibility': 'public',
        })
        .select('id')
        .single();
    final postId = post['id'] as String;

    // 2) upload file & insert ke post_images
    for (var i = 0; i < files.length; i++) {
      final f = files[i];
      final storagePath = await mediaSvc.uploadToStorage(f, user.id);
      await sb.from('post_images').insert({
        'post_id': postId,
        'storage_path': storagePath,
        'mime_type': lookupMimeType(f.path) ?? 'application/octet-stream',
        'order_index': i,
      });
    }

    return postId;
  }

  /// ====== LIKES ======

  Future<void> likePost(String postId) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await sb.from('post_likes').insert({
      'post_id': postId,
      'user_id': user.id,
    });

    // Create notification for post author
    try {
      print('🔔 DEBUG: Starting notification creation for like on post $postId');
      
      final post = await sb
          .from('posts')
          .select('author_id')
          .eq('id', postId)
          .single();
      
      final authorId = post['author_id'] as String;
      print('🔔 DEBUG: Post author ID: $authorId, Current user ID: ${user.id}');
      
      // Get liker's username
      final profile = await sb
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();
      
      final username = profile['username'] as String? ?? 'Someone';
      print('🔔 DEBUG: Liker username: $username');
      
      print('🔔 DEBUG: Calling NotificationRepository.createNotification...');
      final notifId = await _notificationRepo.createNotification(
        userId: authorId,
        type: 'like',
        title: 'New Like',
        body: '$username liked your post',
        actorId: user.id,
        postId: postId,
      );
      
      print('🔔 DEBUG: Notification created! ID: $notifId');
    } catch (e) {
      print('❌ ERROR creating like notification: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> unlikePost(String postId) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await sb
        .from('post_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);
  }

  Future<int> getLikeCount(String postId) async {
    final res = await sb
        .from('post_likes')
        .select('id')
        .eq('post_id', postId);
    final list = res as List;
    return list.length;
  }

  Future<bool> isPostLikedByMe(String postId) async {
    final user = sb.auth.currentUser;
    if (user == null) return false;

    final res = await sb
        .from('post_likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .maybeSingle();

    return res != null;
  }

  /// ====== COMMENTS ======

  Future<String> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final data = {
      'post_id': postId,
      'user_id': user.id,
      'text': text,
    };
    
    if (parentCommentId != null) {
      data['parent_comment_id'] = parentCommentId;
    }

    final row = await sb
        .from('post_comments')
        .insert(data)
        .select('id')
        .single();

    final commentId = row['id'] as String;

    // Create notification for post author
    try {
      final post = await sb
          .from('posts')
          .select('author_id')
          .eq('id', postId)
          .single();
      
      final authorId = post['author_id'] as String;
      
      // Get commenter's username
      final profile = await sb
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();
      
      final username = profile['username'] as String? ?? 'Someone';
      
      await _notificationRepo.createNotification(
        userId: authorId,
        type: 'comment',
        title: 'New Comment',
        body: '$username commented on your post',
        actorId: user.id,
        postId: postId,
        commentId: commentId,
      );
    } catch (e) {
      print('Error creating comment notification: $e');
    }

    return commentId;
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final rows = await sb
        .from('post_comments')
        .select('id, text, user_id, parent_comment_id, created_at')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    final allComments = List<Map<String, dynamic>>.from(rows);

    // Fetch author profiles for comments
    if (allComments.isEmpty) return [];

    final userIds = allComments.map((c) => c['user_id'] as String).toSet().toList();
    final profiles = await fetchProfilesByIds(userIds);

    // Map profiles to comments
    for (final comment in allComments) {
      final userId = comment['user_id'] as String;
      comment['author'] = profiles[userId];
      comment['replies'] = <Map<String, dynamic>>[];
    }

    // Organize comments into parent-reply structure
    final topLevelComments = <Map<String, dynamic>>[];
    final commentMap = <String, Map<String, dynamic>>{};

    // First pass: create map of all comments
    for (final comment in allComments) {
      commentMap[comment['id'] as String] = comment;
    }

    // Second pass: organize into hierarchy
    for (final comment in allComments) {
      final parentId = comment['parent_comment_id'] as String?;
      if (parentId == null) {
        // Top-level comment
        topLevelComments.add(comment);
      } else {
        // Reply to another comment
        final parent = commentMap[parentId];
        if (parent != null) {
          (parent['replies'] as List).add(comment);
        }
      }
    }

    return topLevelComments;
  }

  Future<void> deleteComment(String commentId) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await sb
        .from('post_comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', user.id);
  }

  /// ====== READ (helper) ======

  Future<List<Map<String, dynamic>>> _fetchPostsRange(int from, int to) async {
    final rows = await sb
        .from('posts')
        .select('id, body, author_id, visibility, created_at')
        .order('created_at', ascending: false)
        .range(from, to);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchMediaForPosts(
      List<String> postIds) async {
    if (postIds.isEmpty) return {};

    final res = await sb
        .from('post_images')
        .select('post_id, storage_path, mime_type, order_index')
        .inFilter('post_id', postIds)
        .order('post_id', ascending: true)
        .order('order_index', ascending: true);

    final list = List<Map<String, dynamic>>.from(res);
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final row in list) {
      final pid = row['post_id'] as String;
      grouped.putIfAbsent(pid, () => []).add(row);
    }
    return grouped;
  }

  Future<Map<String, Map<String, dynamic>>> fetchProfilesByIds(
      List<String> userIds) async {
    if (userIds.isEmpty) return {};
    

    
    final res = await sb
        .from('profiles')
        .select('id, username, avatar_url')
        .inFilter('id', userIds);
    
    final list = List<Map<String, dynamic>>.from(res);

    
    final map = {for (final r in list) r['id'] as String: r};

    
    return map;
  }

  String? getCurrentUserId() => sb.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> loadPublicFeed({
    int from = 0,
    int to = 19,
  }) async {
    final posts = await _fetchPostsRange(from, to);
    if (posts.isEmpty) return posts;

    final filtered =
        posts.where((p) => (p['visibility'] ?? 'public') == 'public').toList();

    if (filtered.isEmpty) return [];

    // Fetch all author profiles
    final authorIds = filtered.map((p) => p['author_id'] as String).toSet().toList();
    final profiles = await fetchProfilesByIds(authorIds);

    // Fetch media
    final postIds = filtered.map((p) => p['id'] as String).toList();
    final mediaMap = await fetchMediaForPosts(postIds);

    final currentUserId = getCurrentUserId();
    
    // ✨ OPTIMIZATION: Batch fetch ALL like counts at once
    final likesRes = await sb
        .from('post_likes')
        .select('post_id')
        .inFilter('post_id', postIds);
    
    // Count likes per post
    final likeCountMap = <String, int>{};
    for (final like in likesRes as List) {
      final postId = like['post_id'] as String;
      likeCountMap[postId] = (likeCountMap[postId] ?? 0) + 1;
    }
    
    // ✨ OPTIMIZATION: Batch fetch current user's likes at once
    final Map<String, bool> isLikedMap = {};
    if (currentUserId != null) {
      final myLikesRes = await sb
          .from('post_likes')
          .select('post_id')
          .eq('user_id', currentUserId)
          .inFilter('post_id', postIds);
      
      for (final like in myLikesRes as List) {
        isLikedMap[like['post_id'] as String] = true;
      }
    }
    
    // ✨ OPTIMIZATION: Batch fetch ALL comment counts at once
    final commentsRes = await sb
        .from('post_comments')
        .select('post_id')
        .inFilter('post_id', postIds);
    
    // Count comments per post
    final commentCountMap = <String, int>{};
    for (final comment in commentsRes as List) {
      final postId = comment['post_id'] as String;
      commentCountMap[postId] = (commentCountMap[postId] ?? 0) + 1;
    }
    
    // Map profiles and media to posts
    for (final p in filtered) {
      final pid = p['id'] as String;
      final authorId = p['author_id'] as String;

      // Add author info
      p['author'] = profiles[authorId];
      
      // Add images
      final items = mediaMap[pid] ?? [];
      p['images'] = items.map((m) {
        final path = m['storage_path'] as String;
        return {
          'url': mediaSvc.publicUrl(path),
          'mime_type': m['mime_type'],
          'order': m['order_index'],
        };
      }).toList();

      // Use pre-fetched counts
      p['like_count'] = likeCountMap[pid] ?? 0;
      p['is_liked'] = isLikedMap[pid] ?? false;
      p['comment_count'] = commentCountMap[pid] ?? 0;
    }

    return filtered;
  }

  /// ====== FOLLOW SYSTEM ======

  Future<void> followUser(String userId) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');
    
    try {
      await sb.from('user_follows').insert({
        'follower_id': currentUser.id,
        'following_id': userId,
      });

      // Create notification for followed user
      // Get follower's username
      final profile = await sb
          .from('profiles')
          .select('username')
          .eq('id', currentUser.id)
          .single();
      
      final username = profile['username'] as String? ?? 'Someone';

      await _notificationRepo.createNotification(
        userId: userId, // The person being followed
        type: 'follow',
        title: 'New Follower',
        body: '$username started following you',
        actorId: currentUser.id,
      );

    } catch (e) {
      if (e.toString().contains('409') || e.toString().contains('duplicate key')) {
        print('Already following user $userId');
      } else {
        rethrow;
      }
    }
  }

  Future<void> unfollowUser(String userId) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');
    
    await sb
        .from('user_follows')
        .delete()
        .eq('follower_id', currentUser.id)
        .eq('following_id', userId);
  }

  Future<bool> isFollowing(String userId) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) return false;
    
    final res = await sb
        .from('user_follows')
        .select('id')
        .eq('follower_id', currentUser.id)
        .eq('following_id', userId)
        .maybeSingle();
    
    return res != null;
  }

  Future<int> getFollowerCount(String userId) async {
    final res = await sb
        .from('user_follows')
        .select('id')
        .eq('following_id', userId);
    
    return (res as List).length;
  }

  Future<int> getFollowingCount(String userId) async {
    final res = await sb
        .from('user_follows')
        .select('id')
        .eq('follower_id', userId);
    
    return (res as List).length;
  }

  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    // 1. Get all follower IDs
    final res = await sb
        .from('user_follows')
        .select('follower_id')
        .eq('following_id', userId);
    
    final followerIds = (res as List)
        .map((row) => row['follower_id'] as String)
        .toList();

    if (followerIds.isEmpty) return [];

    // 2. Fetch profiles
    final profilesMap = await fetchProfilesByIds(followerIds);
    return profilesMap.values.toList();
  }

  Future<List<Map<String, dynamic>>> getUsersFollowing(String userId) async {
    // 1. Get all following IDs (users that userId is following)
    final res = await sb
        .from('user_follows')
        .select('following_id')
        .eq('follower_id', userId);
    
    final followingIds = (res as List)
        .map((row) => row['following_id'] as String)
        .toList();

    if (followingIds.isEmpty) return [];

    // 2. Fetch profiles
    final profilesMap = await fetchProfilesByIds(followingIds);
    return profilesMap.values.toList();
  }

  /// ====== FILTERED FEEDS ======

  Future<List<Map<String, dynamic>>> loadFollowingFeed({int from = 0, int to = 9}) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) return [];

    // Get list of users being followed
    final followingRes = await sb
        .from('user_follows')
        .select('following_id')
        .eq('follower_id', currentUser.id);
    
    final followingIds = (followingRes as List)
        .map((f) => f['following_id'] as String)
        .toList();
    
    if (followingIds.isEmpty) return [];

    // Fetch posts from followed users
    final res = await sb
        .from('posts')
        .select('id, body, created_at, author_id')
        .inFilter('author_id', followingIds)
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .range(from, to);

    final posts = List<Map<String, dynamic>>.from(res);
    if (posts.isEmpty) return [];

    return _enrichPostsWithData(posts);
  }

  Future<List<Map<String, dynamic>>> loadLikedPosts({int from = 0, int to = 9}) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) return [];

    // Get posts that user has liked
    final likedRes = await sb
        .from('post_likes')
        .select('post_id')
        .eq('user_id', currentUser.id);
    
    final likedPostIds = (likedRes as List)
        .map((l) => l['post_id'] as String)
        .toList();
    
    if (likedPostIds.isEmpty) return [];

    // Fetch liked posts
    final res = await sb
        .from('posts')
        .select('id, body, created_at, author_id')
        .inFilter('id', likedPostIds)
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .range(from, to);

    final posts = List<Map<String, dynamic>>.from(res);
    if (posts.isEmpty) return [];

    return _enrichPostsWithData(posts);
  }

  Future<List<Map<String, dynamic>>> loadCommentedPosts({int from = 0, int to = 9}) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) return [];

    // Get posts that user has commented on
    final commentedRes = await sb
        .from('post_comments')
        .select('post_id')
        .eq('user_id', currentUser.id);
    
    final commentedPostIds = (commentedRes as List)
        .map((c) => c['post_id'] as String)
        .toSet()
        .toList();
    
    if (commentedPostIds.isEmpty) return [];

    // Fetch commented posts
    final res = await sb
        .from('posts')
        .select('id, body, created_at, author_id')
        .inFilter('id', commentedPostIds)
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .range(from, to);

    final posts = List<Map<String, dynamic>>.from(res);
    if (posts.isEmpty) return [];

    return _enrichPostsWithData(posts);
  }

  /// Load posts by specific user
  Future<List<Map<String, dynamic>>> loadUserPosts({
    required String userId,
    int from = 0,
    int to = 19,
  }) async {
    // Fetch posts from specific user
    final res = await sb
        .from('posts')
        .select('id, body, created_at, author_id, visibility')
        .eq('author_id', userId)
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .range(from, to);

    final posts = List<Map<String, dynamic>>.from(res);
    if (posts.isEmpty) return [];

    return _enrichPostsWithData(posts);
  }

  /// Load current user's own posts
  Future<List<Map<String, dynamic>>> loadMyPosts({
    int from = 0,
    int to = 19,
  }) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) return [];

    return loadUserPosts(userId: currentUser.id, from: from, to: to);
  }

  /// Delete a post (only if user is the author)
  Future<void> deletePost(String postId) async {
    final currentUser = sb.auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    // Delete images first
    final images = await sb
        .from('post_images')
        .select('storage_path')
        .eq('post_id', postId);
    
    for (final img in images as List) {
      final path = img['storage_path'] as String;
      try {
        await mediaSvc.deleteFromStorage(path);
      } catch (e) {
        print('Error deleting image: $e');
      }
    }

    // Delete post (cascade will delete likes, comments, and post_images rows)
    await sb
        .from('posts')
        .delete()
        .eq('id', postId)
        .eq('author_id', currentUser.id); // Safety: only delete own posts
  }

  /// Helper method to enrich posts with authors, images, like/comment counts
  Future<List<Map<String, dynamic>>> _enrichPostsWithData(List<Map<String, dynamic>> posts) async {
    if (posts.isEmpty) return posts;

    final currentUser = sb.auth.currentUser;
    final postIds = posts.map((p) => p['id'] as String).toList();

    // Fetch author profiles
    final authorIds = posts.map((p) => p['author_id'] as String).toSet().toList();
    final profiles = await fetchProfilesByIds(authorIds);

    // Fetch images for all posts
    final mediaMap = await fetchMediaForPosts(postIds);

    // Enrich posts
    for (final p in posts) {
      final pid = p['id'] as String;
      final authorId = p['author_id'] as String;

      // Add author info
      p['author'] = profiles[authorId];

      // Add images
      final items = mediaMap[pid] ?? [];
      p['images'] = items.map((m) {
        final path = m['storage_path'] as String;
        return {
          'url': mediaSvc.publicUrl(path),
          'mime_type': m['mime_type'],
          'order_index': m['order_index'],
        };
      }).toList();

      // Like count and status
      final likesRes = await sb.from('post_likes').select('id').eq('post_id', pid);
      final likesList = likesRes as List;
      p['like_count'] = likesList.length;

      if (currentUser != null) {
        final myLike = await sb
            .from('post_likes')
            .select('id')
            .eq('post_id', pid)
            .eq('user_id', currentUser.id)
            .maybeSingle();
        p['is_liked'] = myLike != null;
      } else {
        p['is_liked'] = false;
      }

      // Comment count
      final commentsRes = await sb.from('post_comments').select('id').eq('post_id', pid);
      final commentsList = commentsRes as List;
      p['comment_count'] = commentsList.length;
    }

    return posts;
  }
}
