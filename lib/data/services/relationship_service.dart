import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_models.dart';
import '../models/notification_models.dart';
import 'notification_service.dart';
import 'auth_service.dart';

enum RelationshipType {
  none,
  following, // Current user follows target
  friend, // Current user and target are friends
  requested, // Current user requested friendship from target
  pending, // Target requested friendship from current user
}

class RelationshipService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final AuthService _authService;
  final NotificationService _notificationService;

  RelationshipService(this._authService, this._notificationService);

  // Helper to standardise document ID for relationships: "userA_userB" where A < B
  String getDocId(int user1, int user2) {
    return user1 < user2 ? "${user1}_$user2" : "${user2}_$user1";
  }

  Future<RelationshipType> getRelationshipStatus(
    UserReference currentUser,
    UserReference targetUser,
  ) async {
    debugPrint(
      'Getting relationship status for user ${currentUser.userId} and ${targetUser.userId}',
    );

    if (currentUser.userId == targetUser.userId) {
      return RelationshipType.none;
    } else if (targetUser.userType == UserType.member) {
      final docId = getDocId(currentUser.userId, targetUser.userId);
      final doc = await _database.collection('relationships').doc(docId).get();

      if (!doc.exists) return RelationshipType.none;

      final data = doc.data()!;
      final status = data['status'] as String?; // 'friend', 'requested'
      final requesterId = data['requesterId'] as int?;

      if (status == 'friend') {
        return RelationshipType.friend;
      } else if (status == 'requested') {
        if (requesterId == currentUser.userId) {
          return RelationshipType.requested;
        } else {
          return RelationshipType.pending;
        }
      } else if (status == 'pending') {
        return RelationshipType.pending;
      } else {
        return RelationshipType.none;
      }
    } else {
      // Check follows (which are stored separately per user usually, or in the relationship doc)
      // For simplicity, let's store follows in a subarray or separate collection if we want 1-way
      // But since follows are Org-driven or Member->Org, they are 1-way.
      // Friends are 2-way.
      // Let's use `follows` collection for 1-way, and `relationships` for 2-way friends.
      // Wait, the plan said "relationships collection".
      // Let's stick to valid Firestore design.
      // Follows: user/{userId}/following/{targetId}

      // Check if following
      final followDoc = await _database
          .collection('users')
          .doc(currentUser.userId.toString())
          .collection('following')
          .doc(targetUser.userId.toString())
          .get();

      if (followDoc.exists) return RelationshipType.following;

      return RelationshipType.none;
    }
  }

  Future<List<UserReference>> getActiveRelationships(int userId) async {
    debugPrint('Getting active relationships for user $userId');
    final following = await _database
        .collection('users')
        .doc(userId.toString())
        .collection('following')
        .get();

    final friendsQuery = await _database
        .collection('relationships')
        .where('status', isEqualTo: 'friend')
        .where('participants', arrayContains: userId)
        .get();

    final ids = <UserReference>{};

    for (var doc in following.docs) {
      ids.add(
        UserReference(
          userId: int.parse(doc.id),
          userType: UserType.organization,
        ),
      );
    }

    for (var doc in friendsQuery.docs) {
      final participants = List<int>.from(doc.data()['participants']);
      ids.addAll(
        participants
            .where((id) => id != userId)
            .map((id) => UserReference(userId: id, userType: UserType.member)),
      );
    }

    return ids.toList();
  }

  Future<void> followUser(
    UserReference currentUser,
    UserReference target,
  ) async {
    debugPrint('Following user ${target.userId}');
    final currentUserData = await _authService.getCurrentUser();
    if (currentUserData != null) {
      await _database
          .collection('users')
          .doc(currentUserData.userId.toString())
          .collection('following')
          .doc(target.userId.toString())
          .set({'createdAt': DateTime.now().toIso8601String()});
      // Create Notification
      await _notificationService.createNotification(
        type: NotificationType.follow,
        recipient: target,
        sender: ContentAuthorPublic(
          userId: currentUserData.userId,
          userType: currentUserData.userType,
          username: currentUserData.username,
          profilePicUrl: currentUserData.profilePicUrl,
        ),
      );
    }
  }

  Future<void> unfollowUser(int currentUserId, int targetId) async {
    debugPrint('Unfollowing user $targetId');
    await _database
        .collection('users')
        .doc(currentUserId.toString())
        .collection('following')
        .doc(targetId.toString())
        .delete();
  }

  Future<void> sendFriendRequest(int currentUserId, int targetId) async {
    debugPrint('Sending friend request to user $targetId');
    final docId = getDocId(currentUserId, targetId);
    await _database.collection('relationships').doc(docId).set({
      'participants': [currentUserId, targetId],
      'status': 'requested',
      'requesterId': currentUserId,
      'createdAt': DateTime.now().toIso8601String(),
    });

    final currentUserData = await _authService.getCurrentUser();
    if (currentUserData != null) {
      await _notificationService.createNotification(
        type: NotificationType.friendRequest,
        recipient: UserReference(userId: targetId, userType: UserType.member),
        sender: ContentAuthorPublic(
          userId: currentUserData.userId,
          userType: currentUserData.userType,
          username: currentUserData.username,
          profilePicUrl: currentUserData.profilePicUrl,
        ),
      );
    }
  }

  Future<void> acceptFriendRequest(int currentUserId, int requesterId) async {
    debugPrint('Accepting friend request from user $requesterId');
    final docId = getDocId(currentUserId, requesterId);
    await _database.collection('relationships').doc(docId).update({
      'status': 'friend',
      'acceptedAt': DateTime.now().toIso8601String(),
    });

    final currentUserData = await _authService.getCurrentUser();
    if (currentUserData != null) {
      await _notificationService.createNotification(
        type: NotificationType.friendAccept,
        recipient: UserReference(
          userId: requesterId,
          userType: UserType.member,
        ),
        sender: ContentAuthorPublic(
          userId: currentUserData.userId,
          userType: currentUserData.userType,
          username: currentUserData.username,
          profilePicUrl: currentUserData.profilePicUrl,
        ),
      );
    }
  }

  Future<void> rejectFriendRequest(int currentUserId, int requesterId) async {
    debugPrint('Rejecting friend request from user $requesterId');
    final docId = getDocId(currentUserId, requesterId);
    await _database.collection('relationships').doc(docId).delete();
  }

  Future<void> unfriend(int currentUserId, int friendId) async {
    debugPrint('Unfriending user $friendId');
    final docId = getDocId(currentUserId, friendId);
    await _database.collection('relationships').doc(docId).delete();
  }

  Future<List<UserPublic>> getIncomingFriendRequests(int userId) async {
    debugPrint('Getting incoming friend requests for user $userId');
    // This is a bit complex as we need to fetch user details.
    // For now, let's assume we can fetch relationship docs then fetch user docs.
    // Ideally we'd store minimal sender info in relationship doc.
    // But let's fetch efficiently.

    final query = await _database
        .collection('relationships')
        .where('status', isEqualTo: 'requested')
        .where('participants', arrayContains: userId)
        .get();

    final requesterIds = <int>[];
    for (var doc in query.docs) {
      final data = doc.data();
      if (data['requesterId'] != userId) {
        requesterIds.add(data['requesterId'] as int);
      }
    }

    // Now fetch users
    if (requesterIds.isEmpty) return [];

    // Firestore `in` query limit is 10. Split if needed or loop.
    // For now, simpler to loop or use getAll and filter if list small.
    // Or just fetch one by one.
    final users = <UserPublic>[];
    for (var id in requesterIds) {
      final userDoc = await _database
          .collection('users')
          .doc(id.toString())
          .get();
      if (userDoc.exists) {
        users.add(UserPublic.fromJson(userDoc.data()!));
      }
    }
    return users;
  }
}
