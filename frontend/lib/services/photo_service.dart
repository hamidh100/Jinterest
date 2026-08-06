import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import '../exceptions/exceptions.dart';
import '../models/comment.dart';
import '../models/photo.dart';
import 'api_client.dart';

class PhotoService {
  static final Map<String, Future<Uint8List>> _photoImageCache = {};
  static Future<List<Photo>> getAllPhotos() async {
    final response = await ApiClient.instance.send(
      method: 'GET',
      route: '/photos',
    );
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> || payload['photos'] is! List) {
      throw StateError('Server returned an invalid photo list');
    }

    return (payload['photos'] as List)
        .whereType<Map<String, dynamic>>()
        .map(_photoFromJson)
        .toList();
  }

  static Photo _photoFromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List? ?? const [])
        .map((category) => category.toString())
        .toList();

    final caption = json['caption'];
    final commentCount = json['commentCount'] as int? ?? 0;

    return Photo(
      uuid: json['id']?.toString() ?? '',
      ownerID: json['ownerId']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryList: categories,
      captionText: caption is Map<String, dynamic>
          ? caption['text']?.toString()
          : null,
      photoAge:
          DateTime.tryParse(json['photoAge']?.toString() ?? '') ??
          DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? true,
      commentsAllowed: json['commentsAllowed'] as bool? ?? true,
      likeIDs: (json['likedByUserIds'] as List? ?? const [])
          .map((userId) => userId.toString())
          .toList(),
      commentIDs: List.generate(
        commentCount,
        (index) => 'server-comment-$index',
      ),
      width: json['width'] as int? ?? 1,
      height: json['height'] as int? ?? 1,
    );
  }

  static Future<List<Photo>> getPhotosByOwner(String ownerId) async {
    final photos = await getAllPhotos();
    return photos.where((photo) => photo.ownerID == ownerId).toList();
  }

  static Future<Photo?> getPhotoById(String photoId) async {
    try {
      final response = await ApiClient.instance.send(
        method: 'GET',
        route: '/photos/$photoId',
      );
      return _photoFromPayload(response);
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      return null;
    }
  }

  static Future<Photo> addPhoto({
    required String ownerId,
    required File imageFile,
    required List<String> categories,
    required bool isPublic,
    required bool commentsAllowed,
    String? name,
    String? caption,
  }) async {
    final imageBytes = await imageFile.readAsBytes();

    final response = await ApiClient.instance.send(
      method: 'POST',
      route: '/photos',
      payload: {
        'ownerId': ownerId,
        'fileName': _fileNameFromPath(imageFile.path),
        'imageBase64': base64Encode(imageBytes),
        'categories': categories,
        'isPublic': isPublic,
        'commentsAllowed': commentsAllowed,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (caption != null && caption.trim().isNotEmpty)
          'caption': caption.trim(),
      },
    );

    return _photoFromPayload(response);
  }

  static String _fileNameFromPath(String path) {
    return path.replaceAll('\\', '/').split('/').last;
  }

  static Future<void> deletePhoto(String photoId) async {
    await ApiClient.instance.send(method: 'DELETE', route: '/photos/$photoId');
  }

  static Future<Photo> updateCommentsAllowed({
    required String photoId,
    required bool commentsAllowed,
  }) async {
    final response = await ApiClient.instance.send(
      method: 'PUT',
      route: '/photos/$photoId',
      payload: {'commentsAllowed': commentsAllowed},
    );
    return _photoFromPayload(response);
  }

  static Future<List<Photo>> searchPhotos(
    String query, {
    String type = 'global',
  }) async {
    if (query.trim().isEmpty) return getAllPhotos();
    final response = await ApiClient.instance.send(
      method: 'POST',
      route: '/search',
      payload: {'type': type, 'text': query.trim()},
    );
    return _photoListFromResponse(response);
  }

  static Future<Photo?> toggleLike({
    required String photoId,
    required String userId,
  }) async {
    try {
      await ApiClient.instance.send(
        method: 'POST',
        route: '/photos/$photoId/likes',
        payload: {'userId': userId},
      );
    } on ApiException catch (error) {
      if (error.statusCode != 409) rethrow;
      await ApiClient.instance.send(
        method: 'DELETE',
        route: '/photos/$photoId/likes',
        payload: {'userId': userId},
      );
    }
    return getPhotoById(photoId);
  }

  static Future<List<Comment>> getComments(String photoId) async {
    final response = await ApiClient.instance.send(
      method: 'GET',
      route: '/photos/$photoId/comments',
    );
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> || payload['comments'] is! List) {
      throw StateError('Server returned an invalid comment list');
    }

    return (payload['comments'] as List)
        .whereType<Map<String, dynamic>>()
        .map(_commentFromJson)
        .toList();
  }

  static Future<Comment> addComment({
    required String photoId,
    required String userId,
    required String text,
  }) async {
    final response = await ApiClient.instance.send(
      method: 'POST',
      route: '/photos/$photoId/comments',
      payload: {'userId': userId, 'text': text.trim()},
    );
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> || payload['comment'] is! Map) {
      throw StateError('Server returned an invalid comment');
    }

    return _commentFromJson(payload['comment'] as Map<String, dynamic>);
  }

  static Future<void> deleteComment(String commentId) async {
    await ApiClient.instance.send(
      method: 'DELETE',
      route: '/comments/$commentId',
    );
  }

  static Comment _commentFromJson(Map<String, dynamic> json) {
    return Comment(
      uuid: json['id']?.toString() ?? '',
      photoID: json['photoId']?.toString() ?? '',
      userID: json['userId']?.toString() ?? '',
      username: json['username']?.toString(),
      text: json['text']?.toString() ?? '',
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static List<Photo> _photoListFromResponse(Map<String, dynamic> response) {
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> || payload['photos'] is! List) {
      throw StateError('Server returned an invalid photo list');
    }
    return (payload['photos'] as List)
        .whereType<Map<String, dynamic>>()
        .map(_photoFromJson)
        .toList();
  }

  static Photo _photoFromPayload(Map<String, dynamic> response) {
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> ||
        payload['photo'] is! Map<String, dynamic>) {
      throw StateError('Server returned an invalid photo');
    }
    return _photoFromJson(payload['photo'] as Map<String, dynamic>);
  }

  static Future<Uint8List> getPhotoImage(String photoId) async {
    final cached = _photoImageCache[photoId];

    if (cached != null) {
      return cached;
    }

    final future = _downloadPhotoImage(photoId);
    _photoImageCache[photoId] = future;

    try {
      return await future;
    } catch (_) {
      _photoImageCache.remove(photoId);
      rethrow;
    }
  }

  static Future<Uint8List> _downloadPhotoImage(String photoId) async {
    final response = await ApiClient.instance.send(
      method: 'GET',
      route: '/photos/$photoId/image',
    );

    final payload = response['payload'];

    if (payload is! Map<String, dynamic> || payload['imageBase64'] is! String) {
      throw StateError('Server returned an invalid photo image');
    }

    return base64Decode(payload['imageBase64'] as String);
  }

  static void clearPhotoImageCache(String photoId) {
    _photoImageCache.remove(photoId);
  }

  static void clearAllPhotoImageCache() {
    _photoImageCache.clear();
  }

  static Future<void> downloadPhoto({
    required String photoId,
    required String photoName,
  }) async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final accessGranted = await Gal.requestAccess();
      if (!accessGranted) {
        throw StateError('Gallery permission was not granted');
      }
    }
    final imageBytes = await getPhotoImage(photoId);
    final fileName = _safeImageName(photoName);
    await Gal.putImageBytes(imageBytes, name: fileName);
  }

  static String _safeImageName(String name) {
    var result = name.trim();
    if (result.isEmpty) {
      result = 'jinterest_photo';
    }
    result = result.replaceAll(RegExp(r'[^\w\s-]'), '');
    result = result.replaceAll(RegExp(r'\s+'), '_');
    if (!result.toLowerCase().endsWith('.jpg') &&
        !result.toLowerCase().endsWith('.jpeg') &&
        !result.toLowerCase().endsWith('.png') &&
        !result.toLowerCase().endsWith('.webp')) {
      result += '.jpg';
    }
    return result;
  }
}
