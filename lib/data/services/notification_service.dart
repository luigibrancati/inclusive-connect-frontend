import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_models.dart';
import '../models/user_models.dart';
import 'auth_service.dart';

class NotificationService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  // ignore: unused_field
  final AuthService _authService;

  NotificationService(this._authService);

  Future<List<NotificationModel>> getNotifications(int userId) async {
    debugPrint('Getting notifications for user $userId');
    try {
      final query = await _database
          .collection('notifications')
          .where('recipient.userId', isEqualTo: userId)
          .get();
      final List<dynamic> list = query.docs.map((doc) => doc.data()).toList();
      list.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint(
        'Error getting notifications for user $userId: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    debugPrint('Marking notification $notificationId as read');
    try {
      await _database
          .collection('notifications')
          .doc(notificationId.toString())
          .update({'isRead': true});
    } catch (e) {
      debugPrint(
        'Error marking notification $notificationId as read: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    debugPrint('Deleting notification $notificationId');
    try {
      await _database
          .collection('notifications')
          .doc(notificationId.toString())
          .delete();
    } catch (e) {
      debugPrint(
        'Error deleting notification $notificationId: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Fetch the largest `id` value from the `notifications` collection.
  Future<int?> _getLargestNotificationId() async {
    debugPrint('Getting largest notification id');
    final query = await _database
        .collection('notifications')
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();
    return data['id'] as int?;
  }

  Future<void> createNotification({
    required NotificationType type,
    required UserReference recipient,
    required ContentAuthorPublic sender,
  }) async {
    debugPrint('Creating notification for user ${recipient.userId}');
    try {
      final lastId = await _getLargestNotificationId();
      final newId = (lastId ?? 0) + 1;
      final now = DateTime.now().toIso8601String();

      final notification = NotificationModel(
        id: newId,
        type: type,
        sender: sender,
        recipient: recipient,
        createdAt: now,
        isRead: false,
      );

      await _database
          .collection('notifications')
          .doc(newId.toString())
          .set(notification.toJson());
    } catch (e) {
      debugPrint('Error creating notification: ${e.toString()}');
      rethrow;
    }
  }
}
