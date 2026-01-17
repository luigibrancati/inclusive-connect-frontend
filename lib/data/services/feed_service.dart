import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:inclusive_connect/data/services/auth_service.dart';
import 'package:inclusive_connect/data/services/storage_service.dart';
import 'package:inclusive_connect/data/services/relationship_service.dart';

import '../models/post_models.dart';
import '../models/user_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedService {
  // final ApiService _apiService;
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final AuthService _authService;
  final StorageService _storageService;

  final RelationshipService _relationshipService;

  FeedService(
    this._authService,
    this._storageService,
    this._relationshipService,
  );

  Future<List<PostPublic>> getFeed() async {
    debugPrint('Getting feed');
    try {
      final currentUser = await _authService.getCurrentUser();

      // Fetch all posts
      final query = await _database.collection('posts').get();
      final List<dynamic> list = query.docs.map((doc) => doc.data()).toList();
      var posts = list.map((e) => PostPublic.fromJson(e)).toList();

      // If user is logged in, prioritize friends/followed
      if (currentUser != null) {
        final activeRelations = await _relationshipService
            .getActiveRelationships(currentUser.userId);
        final activeRelationsIds = activeRelations
            .map((e) => e.userId)
            .toList();

        posts.sort((a, b) {
          final aIsRel = activeRelationsIds.contains(a.author.userId);
          final bIsRel = activeRelationsIds.contains(b.author.userId);

          if (aIsRel && !bIsRel) return -1;
          if (!aIsRel && bIsRel) return 1;

          // Secondary sort by date descending
          final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return bDate.compareTo(aDate);
        });
      } else {
        // Default sort by date
        posts.sort((a, b) {
          final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return bDate.compareTo(aDate);
        });
      }

      return posts;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PostPublic>> getPostsByUser(int userId) async {
    debugPrint('Getting posts by user $userId');
    try {
      final query = await _database
          .collection('posts')
          .where('author.userId', isEqualTo: userId)
          .get();
      final List<dynamic> list = query.docs.map((doc) => doc.data()).toList();
      final posts = list.map((e) => PostPublic.fromJson(e)).toList();
      // Sort by date desc
      posts.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
        final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
        return bDate.compareTo(aDate);
      });
      return posts;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch the largest `postId` value from the `posts` collection.
  // Returns `null` if there are no posts yet.
  Future<int?> _getLargestPostId() async {
    debugPrint('Getting largest post id');
    final query = await _database
        .collection('posts')
        .orderBy('id', descending: true)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final data = query.docs.first.data();
    final id = data['id'] as int?;
    return id;
  }

  Future<PostPublic> createPost(
    String title,
    String body, {
    List<File> images = const [],
    File? audio,
    String? audioBackgroundColorHex,
  }) async {
    debugPrint(
      "Creating post with images: ${images.length} and audio: ${audio != null}",
    );
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }
      final now = DateTime.now().toIso8601String();
      final lastPostId = await _getLargestPostId();
      final newPostId = lastPostId == null ? 0 : lastPostId + 1;
      debugPrint("New post ID: $newPostId");
      List<String> imageUrls = [];
      String? audioUrl;

      if (audio != null) {
        debugPrint("Uploading audio file for post $newPostId");
        audioUrl = await _storageService.uploadPostAudio(
          postId: newPostId,
          audioFile: audio,
        );
        // debugPrint("Uploaded audio file to URL: $audioUrl");
      } else if (images.isNotEmpty) {
        debugPrint("Uploading images for post $newPostId");
        for (var i = 0; i < images.length; i++) {
          // debugPrint("Uploading image $i");
          final url = await _storageService.uploadPostImage(
            postId: newPostId,
            imageId: i,
            file: images[i],
          );
          // debugPrint("Uploaded image $i to URL: $url");
          imageUrls.add(url);
        }
      }

      final newPost = PostPublic(
        id: newPostId,
        contentType: ContentType.post,
        title: title,
        body: body,
        imageUrls: imageUrls,
        audioUrl: audioUrl,
        audioBackgroundColorHex: audioBackgroundColorHex,
        author: ContentAuthorPublic(
          userId: currentUser.userId,
          userType: currentUser.userType,
          username: currentUser.username,
          profilePicUrl: currentUser.profilePicUrl,
        ),
        likes: const [],
        comments: const [],
        createdAt: now,
        lastModifiedAt: now,
      );
      _database
          .collection("posts")
          .doc(newPostId.toString())
          .set(newPost.toJson())
          .onError(
            (e, stack) => debugPrint("Error adding document $e: $stack"),
          );
      return newPost;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likePost(int postId) async {
    debugPrint('Liking post $postId');
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }
      final now = DateTime.now().toIso8601String();
      final postRef = _database.collection("posts").doc(postId.toString());
      final likeData = await postRef.collection('likes').count().get();
      // debugPrint('Current like count result: $likeData');
      final likeNum = likeData.count as int;
      final likeId = likeNum + 1;
      final like = LikeInteraction(
        id: likeId,
        author: ContentAuthorPublic(
          userId: currentUser.userId,
          userType: currentUser.userType,
          username: currentUser.username,
          profilePicUrl: currentUser.profilePicUrl,
        ),
        createdAt: now,
      );
      postRef
          .update({
            'likes': FieldValue.arrayUnion([like.toJson()]),
            'lastModifiedAt': now,
          })
          .then(
            (value) => debugPrint(
              "Added like to post $postId from user ${currentUser.userId}",
            ),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikePost(int postId) async {
    debugPrint('Unliking post $postId');
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }
      final now = DateTime.now().toIso8601String();
      final postRef = _database.collection("posts").doc(postId.toString());
      final likesToRemove = await postRef
          .collection('likes')
          .where('author.userId', isEqualTo: currentUser.userId)
          .get();
      postRef
          .update({
            'likes': FieldValue.arrayRemove(
              likesToRemove.docs.map((doc) => doc.data()).toList(),
            ),
            'lastModifiedAt': now,
          })
          .then(
            (value) => debugPrint(
              "Removed like from user ${currentUser.userId} from post $postId",
            ),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CommentPublic>> getComments(int postId) async {
    debugPrint('Getting comments for post $postId');
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }
      final comments = await _database
          .collection("posts")
          .doc(postId.toString())
          .collection('comments')
          .get();
      final commentList = comments.docs
          .map((doc) => CommentPublic.fromJson(doc.data()))
          .toList();
      return commentList;
    } catch (e) {
      rethrow;
    }
  }

  Future<CommentPublic> addComment(int postId, String body) async {
    debugPrint('Adding comment to post $postId');
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }
      final now = DateTime.now().toIso8601String();
      final postRef = _database.collection("posts").doc(postId.toString());
      final commentData = await postRef.collection('comments').count().get();
      final commentNum = commentData.count as int;
      final commentId = commentNum + 1;
      final comment = CommentPublic(
        id: commentId,
        contentType: ContentType.comment,
        body: body,
        postId: postId,
        author: ContentAuthorPublic(
          userId: currentUser.userId,
          userType: currentUser.userType,
          username: currentUser.username,
          profilePicUrl: currentUser.profilePicUrl,
        ),
        likes: const [],
        createdAt: now,
        lastModifiedAt: now,
      );
      postRef
          .update({
            'comments': FieldValue.arrayUnion([comment.toJson()]),
            'lastModifiedAt': now,
          })
          .then(
            (value) => debugPrint(
              "Added comment to post $postId from user ${currentUser.userId}",
            ),
          );
      return comment;
    } catch (e) {
      rethrow;
    }
  }
}
