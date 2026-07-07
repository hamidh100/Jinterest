import 'package:flutter/material.dart';

import '../models/album.dart';
import '../services/album_service.dart';

class AlbumProvider extends ChangeNotifier {
  List<Album> _albums = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Album> get albums => List.unmodifiable(_albums);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAlbums() async {
    _setLoading(true);

    try {
      _errorMessage = null;
      final result = await AlbumService.getAllAlbums();
      _albums = List<Album>.from(result);
    } catch (e) {
      _errorMessage = 'Failed to load albums: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAlbum(Album album) async {
    _setLoading(true);

    try {
      _errorMessage = null;

      await AlbumService.createAlbum(album);

      final result = await AlbumService.getAllAlbums();
      _albums = List<Album>.from(result);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create album: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAlbum(String albumId) async {
    _setLoading(true);

    try {
      _errorMessage = null;

      await AlbumService.deleteAlbum(albumId);

      final result = await AlbumService.getAllAlbums();
      _albums = List<Album>.from(result);

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete album: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addPhotoToAlbum({
    required String albumId,
    required String photoId,
  }) async {
    try {
      _errorMessage = null;

      final updatedAlbum = await AlbumService.addPhotoToAlbum(
        albumId: albumId,
        photoId: photoId,
      );

      if (updatedAlbum == null) {
        _errorMessage = 'Album not found';
        notifyListeners();
        return false;
      }

      final index = _albums.indexWhere((album) => album.uuid == albumId);

      if (index != -1) {
        _albums[index] = updatedAlbum;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add photo to album: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePhotoFromAlbum({
    required String albumId,
    required String photoId,
  }) async {
    try {
      _errorMessage = null;

      final updatedAlbum = await AlbumService.removePhotoFromAlbum(
        albumId: albumId,
        photoId: photoId,
      );

      if (updatedAlbum == null) {
        _errorMessage = 'Album not found';
        notifyListeners();
        return false;
      }

      final index = _albums.indexWhere((album) => album.uuid == albumId);

      if (index != -1) {
        _albums[index] = updatedAlbum;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove photo from album: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> searchAlbums(String query) async {
    _setLoading(true);

    try {
      _errorMessage = null;

      final result = await AlbumService.searchAlbums(query);
      _albums = List<Album>.from(result);
    } catch (e) {
      _errorMessage = 'Failed to search albums: $e';
    } finally {
      _setLoading(false);
    }
  }

  List<Album> getUserAlbums(String userId) {
    return _albums.where((album) => album.ownerID == userId).toList();
  }

  List<Album> getPublicAlbums() {
    return _albums.where((album) => album.isPublic).toList();
  }

  Album? getAlbumById(String albumId) {
    try {
      return _albums.firstWhere((album) => album.uuid == albumId);
    } catch (_) {
      return null;
    }
  }

  List<Album> getAlbumsContainingPhoto(String photoId) {
    return _albums.where((album) => album.photoIDs.contains(photoId)).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
