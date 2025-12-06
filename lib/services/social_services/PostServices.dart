// post_service.dart
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_media_service.dart';

class PostService {
  final sb = Supabase.instance.client;
  final mediaSvc = PostMediaService();

  /// ====== CREATE ======

  Future<String> createPost({required String body}) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final row = await sb
        .from('posts')
        .insert({
          'author_id': user.id,   // pastikan kolom DB sudah author_id
          'body': body,           // dan kolom 'body'
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
    return {for (final r in list) r['id'] as String: r};
  }

  /// ====== READ (public feed lengkap: posts + images + profile) ======
  ///
  /// return: List<Map> dengan shape:
  /// {
  ///   id, body, author_id, created_at, visibility,
  ///   images: [ { url, mime, order } ... ],
  ///   author: { id, username, avatar_url }   // kalau ada
  /// }
  Future<List<Map<String, dynamic>>> loadPublicFeed({
    int from = 0,
    int to = 19,
  }) async {
    final posts = await _fetchPostsRange(from, to);
    if (posts.isEmpty) return posts;

    final filtered = posts
        .where((p) => (p['visibility'] ?? 'public') == 'public')
        .toList();

    if (filtered.isEmpty) return [];

    final postIds = filtered.map((p) => p['id'] as String).toList();
    final mediaMap = await fetchMediaForPosts(postIds);

    final authorIds = filtered.map((p) => p['author_id'] as String).toSet().toList();
    final profiles = await fetchProfilesByIds(authorIds);

    for (final p in filtered) {
      final pid = p['id'] as String;

      final items = mediaMap[pid] ?? const [];
      p['images'] = items.map((m) {
        final path = m['storage_path'] as String;
        return {
          'url': mediaSvc.publicUrl(path),        
          'order': m['order_index'],
        };
      }).toList();

      final aid = p['author_id'] as String;
      p['author'] = profiles[aid];
    }

    return filtered;
  }
}
