import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  StorageService();

  /// Uploads a profile picture for a specific user.
  /// Path: `profile-pics/user-<id>/image.png`
  Future<String> uploadProfilePicture({
    required int userId,
    required File file,
  }) async {
    final storagePath = 'profile-pics/user-$userId/image.png';
    final ref = _storage.ref().child(storagePath);
    final task = ref.putFile(file);
    final snapshot = await task;
    return snapshot.ref.fullPath;
  }

  /// Uploads a post image.
  /// Path: `post-images/post-<id>/image-<id>.png`
  Future<String> uploadPostImage({
    required int postId,
    required int imageId,
    required File file,
  }) async {
    debugPrint("Uploading post image $postId/image-$imageId");
    final storagePath = 'post-images/post-$postId/image-$imageId.png';
    final ref = _storage.ref().child(storagePath);
    final task = ref.putFile(file);
    final snapshot = await task;
    return snapshot.ref.fullPath;
  }

  /// Uploads a post audio file.
  /// Path: `post-images/post-<id>/image-<id>.png`
  Future<String> uploadPostAudio({
    required int postId,
    required File audioFile,
  }) async {
    debugPrint("Uploading audio file post-$postId/audio/audioFile");
    final extension = audioFile.path.split('.').last;
    final storagePath = 'post-audios/post-$postId/audio/audioFile.$extension';
    final ref = _storage.ref().child(storagePath);
    final task = ref.putFile(audioFile);
    final snapshot = await task;
    return snapshot.ref.fullPath;
  }

  /// Uploads an event image.
  /// Path: `event-images/event-<id>/image-<id>.png`
  Future<String> uploadEventImage({
    required int eventId,
    required int imageId,
    required File file,
  }) async {
    debugPrint("Uploading event image $eventId/image-$imageId");
    final storagePath = 'event-images/event-$eventId/image-$imageId.png';
    final ref = _storage.ref().child(storagePath);
    final task = ref.putFile(file);
    final snapshot = await task;
    return snapshot.ref.fullPath;
  }

  /// Gets the download URL for a given path or gs:// URL.
  Future<String> getDownloadUrl(String pathOrUrl) async {
    // debugPrint("Getting download URL for $pathOrUrl");
    if (pathOrUrl.startsWith('gs://')) {
      return await _storage.refFromURL(pathOrUrl).getDownloadURL();
    } else {
      return await _storage.ref().child(pathOrUrl).getDownloadURL();
    }
  }

  Future<Uint8List?> getImageData(String pathOrUrl) async {
    Uint8List? imageBytes;
    imageBytes = await _storage.ref().child(pathOrUrl).getData().catchError((
      error,
    ) {
      debugPrint("Error getting image data for $pathOrUrl: $error");
      return null;
    });
    return imageBytes;
  }
}
