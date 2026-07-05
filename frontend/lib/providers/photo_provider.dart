import 'package:flutter/material.dart';

import '../models/photo.dart';
import '../services/photo_service.dart';

class PhotoProvider extends ChangeNotifier {
  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Photo> get photos => List.unmodifiable(_photos);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPhotos() async {
    _setLoading(true);

    try {
      _errorMessage = null;
      final result = await PhotoService.getAllPhotos();
      _photos = List<Photo>.from(result);
    } catch (e) {
      _errorMessage = 'Failed to load photos: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addPhoto(Photo photo) async {
    _setLoading(true);

    try {
      _errorMessage = null;
      await PhotoService.addPhoto(photo);
      final result = await PhotoService.getAllPhotos();
      _photos = List<Photo>.from(result);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add photo: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    _setLoading(true);

    try {
      _errorMessage = null;
      await PhotoService.deletePhoto(photoId);
      final result = await PhotoService.getAllPhotos();
      _photos = List<Photo>.from(result);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete photo: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchPhotos(String query) async {
    _setLoading(true);

    try {
      _errorMessage = null;
      final result = await PhotoService.searchPhotos(query);
      _photos = List<Photo>.from(result);
    } catch (e) {
      _errorMessage = 'Failed to search photos: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleLike({
    required String photoId,
    required String userId,
  }) async {
    try {
      _errorMessage = null;

      final updatedPhoto = await PhotoService.toggleLike(
        photoId: photoId,
        userId: userId,
      );

      if (updatedPhoto == null) {
        _errorMessage = 'Photo not found';
        notifyListeners();
        return;
      }

      final index = _photos.indexWhere((photo) => photo.uuid == photoId);

      if (index != -1) {
        _photos[index] = updatedPhoto;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update like: $e';
      notifyListeners();
    }
  }

  List<Photo> getLikedPhotos(String userId) {
    return _photos.where((photo) => photo.likeIDs.contains(userId)).toList();
  }

  List<Photo> getUserPhotos(String userId) {
    return _photos.where((photo) => photo.ownerID == userId).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
