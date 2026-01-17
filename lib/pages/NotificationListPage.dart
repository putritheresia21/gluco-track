import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/NotificationRepository.dart';
import 'package:intl/intl.dart';
import 'package:glucotrack_app/pages/NavbarItem/GlucoseChartPage.dart';
import 'package:glucotrack_app/pages/ReportsPage.dart';
import 'package:glucotrack_app/pages/SocialMedia/feeds.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final _notificationRepo = NotificationRepository();
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final notifications = await _notificationRepo.getNotifications(limit: 50);
      final unreadCount = await _notificationRepo.getUnreadCount();
      
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadCount = unreadCount;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) (setState(() => _loading = false));
    }
  }

  Future<void> _markAllAsRead() async {
    await _notificationRepo.markAllAsRead();
    _loadNotifications();
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'mention':
        return Icons.alternate_email;
      case 'follow':
        return Icons.person_add;
      case 'reminder':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'mention':
        return Colors.purple;
      case 'follow':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all as read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final type = notif['type'] as String;
                      final title = notif['title'] as String;
                      final body = notif['body'] as String;
                      final read = notif['read'] as bool;
                      final createdAt = DateTime.parse(notif['created_at'] as String);
                      final actor = notif['actor'] as Map<String, dynamic>?;
                      final avatarUrl = actor?['avatar_url'] as String?;
                      final username = actor?['username'] as String? ?? 'User';

                      return Dismissible(
                        key: Key(notif['id'] as String),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _notificationRepo.deleteNotification(notif['id'] as String);
                          setState(() {
                            _notifications.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification deleted')),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getIconColor(type).withOpacity(0.1),
                            child: Icon(
                              _getIcon(type),
                              color: _getIconColor(type),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: read ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(body),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTimestamp(createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (!read)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          tileColor: read ? null : Colors.blue.withOpacity(0.05),
                          onTap: () async {
                            // Mark as read
                            if (!read) {
                              await _notificationRepo.markAsRead(notif['id'] as String);
                              setState(() {
                                notif['read'] = true;
                                _unreadCount--;
                              });
                            }

                            // Navigate based on notification type
                            _navigateToContent(context, notif);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _navigateToContent(BuildContext context, Map<String, dynamic> notif) {
    final type = notif['type']?.toString() ?? '';
    final postId = notif['post_id']?.toString();
    
    switch (type.toLowerCase()) {
      case 'like':
      case 'comment':
        // Navigate to social feed (or specific post if implemented)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublicFeedPage()),
        );
        break;
      case 'reminder':
      case 'glucose_reminder':
        // Navigate to glucose chart
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GlucoseChart()),
        );
        break;
      case 'report':
        // Navigate to reports page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportsPage()),
        );
        break;
      default:
        // Show a snackbar for unknown types
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening: $type notification')),
        );
    }
  }
}
