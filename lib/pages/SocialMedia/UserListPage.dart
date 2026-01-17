import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/SocialMedia/UserProfilePage.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';

class UserListPage extends StatefulWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> Function() loadUsers;
  final int? initialCount;

  const UserListPage({
    super.key,
    required this.title,
    required this.loadUsers,
    this.initialCount,
  });

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  late int _userCount;

  @override
  void initState() {
    super.initState();
    _userCount = widget.initialCount ?? 0;
    _usersFuture = widget.loadUsers().then((users) {
      if (mounted) {
        setState(() {
          _userCount = users.length;
        });
      }
      return users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.title} ($_userCount)', // Always show count
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              final username = user['username'] ?? 'User';
              final avatarUrl = user['avatar_url'];
              final userId = user['id'];

              return ListTile(
                dense: true, // Makes the tile more compact
                visualDensity: VisualDensity.compact, // Reduces vertical spacing
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                leading: CircleAvatar(
                  radius: 18, // Slightly smaller avatar
                  backgroundImage:
                      (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl)
                          : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(username[0].toUpperCase(), style: const TextStyle(fontSize: 14))
                      : null,
                ),
                title: Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                onTap: () {
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          userId: userId,
                          username: username,
                          avatarUrl: avatarUrl,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
