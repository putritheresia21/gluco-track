import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final sb = Supabase.instance.client;

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
}