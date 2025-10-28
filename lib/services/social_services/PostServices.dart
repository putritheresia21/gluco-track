import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_media_service.dart';

class PostService {
  final sb = Supabase.instance.client;
  final media = PostMediaService();

  static const String bucket = 'post-images';

  Future<String> createPost({required String body}) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final row = await sb.from('posts').insert({
      'author_id': user.id,
      'body': body,
      'visibility': 'public',
    }).select('id').single();

    return row['id'] as String;
  }

  Future<List<Map<String, dynamic>>> fetchPublicPosts({int from = 0, int to = 9}) async {
    final rows = await sb
        .from('posts')
        .select('id, body, author_id, created_at')
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .range(from, to);

    return List<Map<String, dynamic>>.from(rows);
  }

  /// Ambil profile untuk daftar userId
  Future<Map<String, Map<String, dynamic>>> fetchProfilesByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final res = await sb
        .from('profiles')
        .select('id, username, avatar_url')
        .inFilter('id', userIds);

    final list = List<Map<String, dynamic>>.from(res);
    return {for (final row in list) row['id'] as String: row};
  }

  
  Future<String> createPostWithImages({
    required String body,
    required List<File> files,
  }) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final post = await sb.from('posts').insert({
      'author_id': user.id,
      'body': body,
      'visibility': 'public',
    }).select('id').single();
    final postId = post['id'] as String;

    for (var i = 0; i < files.length; i++) {
      final f = files[i];

      final storagePath = await media.uploadToStorage(f, user.id);

      // Simpan metadata ke tabel post_images
      await sb.from('post_images').insert({
        'post_id': postId,
        'storage_path': storagePath,                            
        'mime_type': lookupMimeType(f.path) ?? 'application/octet-stream',
        'order_index': i,
      });
    }

    return postId;
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchMediaForPosts(List<String> postIds) async {
    if (postIds.isEmpty) return {};

    final res = await sb
        .from('post_images')
        .select('post_id, storage_path, mime_type, order_index')
        .inFilter('post_id', postIds)
        .order('order_index', ascending: true);

    final list = List<Map<String, dynamic>>.from(res);
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final row in list) {
      final pid = row['post_id'] as String;
      grouped.putIfAbsent(pid, () => []).add(row);
    }
    return grouped;
  }

  String getPublicUrl(String storagePath) {
    return sb.storage.from(bucket).getPublicUrl(storagePath);
  }
}
