import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';
import 'package:glucotrack_app/Widget/post_composser.dart';

class PublicFeedPage extends StatefulWidget {
  const PublicFeedPage({super.key});

  @override
  State<PublicFeedPage> createState() => _PublicFeedPageState();
}

class _PublicFeedPageState extends State<PublicFeedPage> {
  final _svc = PostService();
  final _posts = <Map<String, dynamic>>[];
  Map<String, Map<String, dynamic>> _profiles = {};
  bool _loading = false;
  bool _end = false;
  int _page = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (reset) {
        _posts.clear();
        _profiles = {};
        _end = false;
        _page = 0;
      }
      final from = _page * _pageSize;
      final to = from + _pageSize - 1;

      final rows = await _svc.fetchPublicPosts(from: from, to: to);

      final ids = rows.map((r) => r['author_id'] as String).toSet().toList();
      final missing = ids.where((id) => !_profiles.containsKey(id)).toList();
      if (missing.isNotEmpty) {
        final fetched = await _svc.fetchProfilesByIds(missing);
        _profiles.addAll(fetched);
      }

      _posts.addAll(rows);
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

  Future<void> _refresh() => _load(reset: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Feed')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: _posts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return PostComposer(onPosted: () => _refresh());
            }

            final i = index - 1;
            if (i >= _posts.length) {
              if (!_end) _load();
              return _loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            final p = _posts[i];
            final authorId = p['author_id'] as String;
            final profile = _profiles[authorId];
            final username = (profile?['username'] as String?) ?? 'User';
            final avatarUrl = profile?['avatar_url'] as String?;
            final body = (p['body'] as String?) ?? '';
            final createdAt =
                DateTime.tryParse(p['created_at'] ?? '') ?? DateTime.now();

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Avatar(avatarUrl: avatarUrl, username: username),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Header(username: username, createdAt: createdAt),
                            const SizedBox(height: 6),
                            Text(body, style: const TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
      backgroundImage:
          (avatarUrl != null && avatarUrl!.isNotEmpty) ? NetworkImage(avatarUrl!) : null,
      child: (avatarUrl == null || avatarUrl!.isEmpty)
          ? Text(initial, style: const TextStyle(fontWeight: FontWeight.bold))
          : null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.username, required this.createdAt});
  final String username;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('dd MMM yyyy • HH:mm').format(createdAt);
    return Row(
      children: [
        Expanded(
          child: Text(
            username,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          ts,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
