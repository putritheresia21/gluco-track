import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_media_service.dart';
import 'dart:io';
import 'package:mime/mime.dart';

class PostService {
  final sb = Supabase.instance.client;
  final media = PostMediaService();

  Future<String> createPost({required String body}) async {
    final user = sb.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final row = await sb.from('posts').insert({
      'author_id': user.id,
      'body': body,
      'visibility': 'public',
    }).select().single();

    return row['id'] as String;
  }

  Future<List<Map<String, dynamic>>> fetchPublicPosts({int from = 0, int to = 9}) async {
    final response = await sb
        .from('posts')
        .select('id, body, author_id, created_at')
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .range(from, to);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, Map<String, dynamic>>> fetchProfilesByIds(List<String> userIds,) async{
    if (userIds.isEmpty) return {};
    final response = await sb
        .from('profiles')
        .select('id, username, avatar_url')
        .inFilter('id', userIds);
    final list = List<Map<String, dynamic>>.from(response);
    return {for (var row in list) row['id']: row};
  }

  Future<String> createPostWithImages({
    required String body,
    required List<File> files,
  }) async {
    final user = sb.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final post = await sb.from('posts').insert({
      'author_id': user.id,
      'body': body,
      'visibility': 'public',
    }).select('id').single();

    final postId = post['id'] as String;

    for (final f in files){
      final path = await media.uploadToStorage(f, user.id);
      await sb.from('post_media').insert({
        'post_id': postId,
        'object_path': path,
        'mime': lookupMimeType(f.path) ?? 'application/octet-stream',
      });
    }

    return postId;
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchMediaForPosts(List<String> postIds) async {
    if (postIds.isEmpty) return {};
    final response = await sb
        .from('post_images')
        .select('post_id, object_path')
        .inFilter('post_id', postIds);
    final list = List<Map<String, dynamic>>.from(response);
    final map = <String, List<Map<String, dynamic>>>{};
    for (final row in list) {
      final pid = row['post_id'] as String;
      map.putIfAbsent(pid, () => []).add(row);
    }
    return map;
  }
}