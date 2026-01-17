import 'package:flutter/foundation.dart';
import '../models/user_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  // final ApiService _apiService;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final _searchDb = Supabase.instance.client;
  final CacheService _cache;

  UserService(this._cache);

  Future<UserPublic> getUser(int userId) async {
    try {
      final query = await _database.collection('users').doc("$userId").get();
      return UserPublic.fromJson(query.data()!);
    } catch (e) {
      rethrow;
    }
  }

  // Placeholder for search/discover if API supports it,
  // currently Swagger shows 'get all members' / 'get all organizations' which could be used for discover.
  Future<List<UserPublic>> getAllUsers() async {
    try {
      final query = await _database.collection('users').get();
      final List<dynamic> list = query.docs.map((doc) => doc.data()).toList();
      return list.map((e) => UserPublic.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(UserPublic user) async {
    try {
      final doc = await _database
          .collection('users')
          .doc("${user.userId}")
          .get();
      final updateSearchIndex = doc.data()!['username'] != user.username;
      if (!doc.exists) {
        throw Exception('User not found');
      }
      await doc.reference.update(user.toJson());
      if (updateSearchIndex) {
        debugPrint("Updating username in search index");
        await _searchDb.from('text_search').update({
          'username': user.username,
        }).eq('user_id', user.userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserPublic>> searchUsers(String fuzzyUsername) async {
    if (fuzzyUsername.isEmpty) return [];

    final cacheKey = 'user_search_${fuzzyUsername}';
    List<int> userIds;

    // Check cache
    final cachedData = await _cache.get(cacheKey);
    if (cachedData != null) {
      userIds = List<int>.from(cachedData);
    } else {
      try {
        final query_result = await _searchDb.from('text_search').select().textSearch('username', "'$fuzzyUsername'");
        print("Supabase search result: $query_result");
        userIds = query_result.map((doc) => doc['user_id'] as int).toList();
        debugPrint("searchUsers results: $userIds");

        // Cache for 10 minutes
        await _cache.save(
          cacheKey,
          userIds,
          DateTime.now().add(const Duration(minutes: 10)),
        );
      } catch (e) {
        debugPrint("Error searching users: $e");
        rethrow;
      }
    }

    final results = await _database.collection('users')
        .where('userId', whereIn: userIds)
        .get();
    return results.docs
        .map((doc) => UserPublic.fromJson(doc.data()))
        .toList();
  }
}
