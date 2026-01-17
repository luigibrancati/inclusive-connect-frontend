import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:inclusive_connect/data/models/common_models.dart';
import 'package:inclusive_connect/data/models/user_models.dart';
import 'package:inclusive_connect/data/services/auth_service.dart';
import 'package:inclusive_connect/data/services/storage_service.dart';
import '../models/event_models.dart';

class EventService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final AuthService _authService;
  final StorageService _storageService;

  EventService(this._authService, this._storageService);

  Future<int?> _getLargestEventId() async {
    final query = await _database
        .collection('events')
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();
    final id = data['id'] as int?;
    return id;
  }

  Future<List<Event>> getEvents({required int? userOrganizationId}) async {
    try {
      final snapshot = await _database.collection('events').get();
      final events = snapshot.docs
          .map((doc) => Event.fromJson(doc.data()))
          .toList();
      // Client-side sort: Prioritize user's organization
      if (userOrganizationId != null) {
        events.sort((a, b) {
          final aIsOrg = a.author.userId == userOrganizationId;
          final bIsOrg = b.author.userId == userOrganizationId;
          if (aIsOrg && !bIsOrg) return -1;
          if (!aIsOrg && bIsOrg) return 1;
          // Secondary sort by date (newest first) or generic
          return b.dateTime.compareTo(a.dateTime);
        });
      } else {
        // Default sort by date
        events.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      }
      return events;
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  }

  Future<void> createEvent(
    String title,
    String description,
    LocationData locationData,
    DateTime dateTime, {
    List<File> images = const [],
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }
      final now = DateTime.now().toIso8601String();
      final largestId = await _getLargestEventId();
      final newId = largestId == null ? 1 : largestId + 1;

      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final path = await _storageService.uploadEventImage(
            eventId: newId,
            imageId: i,
            file: images[i],
          );
          imageUrls.add(path);
        }
      }

      final newEvent = Event(
        id: newId,
        title: title,
        description: description,
        locationData: locationData,
        dateTime: dateTime.toIso8601String(),
        author: ContentAuthorPublic(
          userId: currentUser.userId,
          userType: currentUser.userType,
          username: currentUser.username,
          profilePicUrl: currentUser.profilePicUrl,
        ),
        createdAt: now,
        lastModifiedAt: now,
        imageUrls: imageUrls,
      );

      await _database
          .collection('events')
          .doc("${newEvent.id}")
          .set(newEvent.toJson());
    } catch (e) {
      debugPrint('Error creating event: $e');
      rethrow;
    }
  }
}
