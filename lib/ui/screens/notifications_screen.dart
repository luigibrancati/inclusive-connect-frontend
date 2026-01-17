import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/relationship_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/notification_models.dart';
import 'package:go_router/go_router.dart';
import '../../ui/widgets/cached_storage_image.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      // Assuming we can get current user ID easily.
      // Ideally we pass it or get it from AuthService in the future builder.
      _notificationsFuture = _loadNotifications();
    });
  }

  Future<List<NotificationModel>> _loadNotifications() async {
    final authService = context.read<AuthService>();
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) return [];
    // ignore: use_build_context_synchronously
    return context.read<NotificationService>().getNotifications(
      currentUser.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(context, notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
  ) {
    String text = '';
    Widget? trailing;

    switch (notification.type) {
      case NotificationType.follow:
        text = "${notification.sender.username} followed you.";
        break;
      case NotificationType.friendRequest:
        text = "${notification.sender.username} sent you a friend request.";
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _acceptRequest(notification),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text("Accept"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _rejectRequest(notification),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Reject"),
            ),
          ],
        );
        break;
      case NotificationType.friendAccept:
        text = "${notification.sender.username} accepted your friend request.";
        break;
    }

    return ListTile(
      leading: GestureDetector(
        onTap: () => context.push('/users/${notification.sender.userId}'),
        child: notification.sender.profilePicUrl != null
            ? CachedStorageImage(
                notification.sender.profilePicUrl!,
                width: 40,
                height: 40,
                circle: true,
              )
            : const CircleAvatar(child: Icon(Icons.person)),
      ),
      title: Text(text),
      subtitle: Text(
        // Simple date formatting
        DateTime.parse(
          notification.createdAt,
        ).toLocal().toString().split('.')[0],
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: trailing,
      onTap: () {
        if (notification.type != NotificationType.friendRequest) {
          context.push('/users/${notification.sender.userId}');
        }
      },
    );
  }

  Future<void> _acceptRequest(NotificationModel notification) async {
    try {
      final authService = context.read<AuthService>();
      final relationshipService = context.read<RelationshipService>();
      final notificationService = context.read<NotificationService>();
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        await relationshipService.acceptFriendRequest(
          currentUser.userId,
          notification.sender.userId,
        );
        await notificationService.deleteNotification(notification.id);
        _refreshNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _rejectRequest(NotificationModel notification) async {
    try {
      final authService = context.read<AuthService>();
      final relationshipService = context.read<RelationshipService>();
      final notificationService = context.read<NotificationService>();
      final currentUser = await authService.getCurrentUser();
      if (currentUser != null) {
        await relationshipService.rejectFriendRequest(
          currentUser.userId,
          notification.sender.userId,
        );
        await notificationService.deleteNotification(notification.id);
        _refreshNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
