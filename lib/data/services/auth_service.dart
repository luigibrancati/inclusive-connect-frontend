import 'package:flutter/foundation.dart';
import 'package:inclusive_connect/data/models/common_models.dart';
import '../models/user_models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final _searchDb = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CacheService _cache;
  final String _currentUserCacheKey = 'current_user';
  final int _authCacheDurationDays = 7;

  AuthService(this._cache);

  Future<void> login(String email, String password, UserType userType) async {
    try {
      final currentUser = await _cache.get(_currentUserCacheKey);
      if (currentUser != null) {
        return;
      }
      debugPrint('Logging in with email $email and password $password');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Login successful with user ${credential.user!.uid}');
      final currentUserData = await getCurrentUser();
      await _cache.save(
        _currentUserCacheKey,
        currentUserData!.toJson(),
        DateTime.now().add(Duration(days: _authCacheDurationDays)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPublic> registerOrganization(UserCreate org) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: org.email,
        password: org.password,
      );
      final now = DateTime.now().toIso8601String();
      final lastUserId = await _getLargestUserId();
      final newOrg = UserPublic(
        userId: lastUserId == null ? 0 : lastUserId + 1,
        userType: UserType.organization,
        username: org.username,
        email: org.email,
        profilePicUrl: null,
        bio: org.bio,
        residentialData: org.residentialData,
        fiscalData: org.fiscalData,
        createdAt: now,
        lastModifiedAt: now,
      );
      _database
          .collection("users")
          .add(newOrg.toJson())
          .then(
            (DocumentReference doc) =>
                debugPrint('DocumentSnapshot added with ID: ${doc.id}'),
            onError: (e) => debugPrint("Error adding document $e"),
          );
      _searchDb.from('text_search').insert({
        'user_id': newOrg.userId,
        'username': newOrg.username,
      });
      await _cache.save(
        _currentUserCacheKey,
        newOrg.toJson(),
        DateTime.now().add(Duration(days: _authCacheDurationDays)),
      );
      return newOrg;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch the largest `userId` value from the `users` collection.
  // Returns `null` if there are no users yet.
  Future<int?> _getLargestUserId() async {
    final query = await _database
        .collection('users')
        .orderBy('userId', descending: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();
    final id = data['userId'] as int?;
    return id;
  }

  // Fetch the `organizationId` value from the `inviteCodes` collection.
  // Returns `null` if there are no inviteCodes yet.
  Future<int> getInviteCodeOrgId(String code) async {
    debugPrint('Looking for invite code: $code');
    final query = await _database
        .collection('inviteCodes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw Exception('Invite code not found or invalid');
    }
    if (query.docs.length > 1) {
      throw Exception('Duplicate invite codes found');
    }
    debugPrint('Invite code document found');
    final inviteCode = InviteCode.fromJson(query.docs.first.data());
    debugPrint('Invite code found: ${inviteCode.code}');
    final now = DateTime.now();
    debugPrint('Expiration date: ${inviteCode.expiresAt}');
    final expirationDate = inviteCode.expiresAt != null
        ? DateTime.parse(inviteCode.expiresAt!)
        : DateTime.now().subtract(const Duration(days: 3650));
    if (inviteCode.expiresAt != null && now.isAfter(expirationDate)) {
      throw Exception('Invite code has expired');
    }
    if (!inviteCode.isValid) {
      throw Exception('Invite code is no longer valid');
    }
    if (inviteCode.currentUses >= inviteCode.maxUses!) {
      throw Exception('Invite code has reached its maximum uses');
    }
    return inviteCode.organizationId;
  }

  Future<UserPublic> registerMember(UserCreate member) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: member.email,
        password: member.password,
      );
      final now = DateTime.now().toIso8601String();
      final lastUserId = await _getLargestUserId();
      final newMember = UserPublic(
        userId: lastUserId == null ? 0 : lastUserId + 1,
        inviteCode: member.inviteCode,
        organizationId: member.organizationId,
        userType: UserType.member,
        username: member.username,
        email: member.email,
        profilePicUrl: null,
        bio: member.bio,
        createdAt: now,
        lastModifiedAt: now,
      );
      _database
          .collection("users")
          .add(newMember.toJson())
          .then(
            (DocumentReference doc) =>
                debugPrint('DocumentSnapshot added with ID: ${doc.id}'),
            onError: (e) => debugPrint("Error adding document $e"),
          );
      _searchDb.from('text_search').insert({
        'user_id': newMember.userId,
        'username': newMember.username,
      });
      await _cache.save(
        _currentUserCacheKey,
        newMember.toJson(),
        DateTime.now().add(Duration(days: _authCacheDurationDays)),
      );
      return newMember;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserPublic?> getCurrentUser() async {
    try {
      final cachedUser = await _cache.get(_currentUserCacheKey);
      if (cachedUser != null) {
        return UserPublic.fromJson(cachedUser);
      }
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      final doc = await _database
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      if (doc.docs.isEmpty) {
        throw Exception('User data not found');
      }
      final data = doc.docs.first.data();
      if (!data.containsKey('userType')) {
        throw Exception('Invalid user data');
      }
      final currentUser = UserPublic.fromJson(data);
      await _cache.save(
        _currentUserCacheKey,
        currentUser.toJson(),
        DateTime.now().add(Duration(days: _authCacheDurationDays)),
      );
      return currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserReference?> getUser(int userId) async {
    try {
      final doc = await _database
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (doc.docs.isEmpty) {
        throw Exception('User data not found');
      }
      final data = doc.docs.first.data();
      if (!data.containsKey('userType')) {
        throw Exception('Invalid user data');
      }
      return UserPublic.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      debugPrint("logout: logging out");
      await _auth.signOut();
      await _cache.remove(_currentUserCacheKey);
    } catch (e) {
      debugPrint("logout: error logging out: ${e.toString()}");
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      debugPrint("isLoggedIn: checking if logged in");
      final user = await _cache.get(_currentUserCacheKey);
      debugPrint("isLoggedIn user: $user");
      return user != null;
    } catch (e) {
      debugPrint("isLoggedIn: error checking if logged in: ${e.toString()}");
      rethrow;
    }
  }
}
