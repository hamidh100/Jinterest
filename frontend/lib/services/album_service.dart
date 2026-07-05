import '../models/album.dart';

class AlbumService {
  static final List<Album> _albums = [];

  static Future<List<Album>> getAllAlbums() async {
    return List.unmodifiable(_albums);
  }

  static Future<List<Album>> getAlbumsByOwner(String ownerId) async {
    return _albums.where((album) => album.ownerID == ownerId).toList();
  }

  static Future<List<Album>> getPublicAlbums() async {
    return _albums.where((album) => album.isPublic).toList();
  }

  static Future<Album?> getAlbumById(String albumId) async {
    try {
      return _albums.firstWhere((album) => album.uuid == albumId);
    } catch (_) {
      return null;
    }
  }

  static Future<Album> createAlbum(Album album) async {
    _albums.insert(0, album);
    return album;
  }

  static Future<void> deleteAlbum(String albumId) async {
    _albums.removeWhere((album) => album.uuid == albumId);
  }

  static Future<Album?> addPhotoToAlbum({
    required String albumId,
    required String photoId,
  }) async {
    final index = _albums.indexWhere((album) => album.uuid == albumId);

    if (index == -1) return null;

    final album = _albums[index];

    if (album.photoIDs.contains(photoId)) {
      return album;
    }

    final updatedPhotoIds = List<String>.from(album.photoIDs)..add(photoId);

    final updatedAlbum = album.copyWith(photoIDs: updatedPhotoIds);

    _albums[index] = updatedAlbum;
    return updatedAlbum;
  }

  static Future<Album?> removePhotoFromAlbum({
    required String albumId,
    required String photoId,
  }) async {
    final index = _albums.indexWhere((album) => album.uuid == albumId);

    if (index == -1) return null;

    final album = _albums[index];

    final updatedPhotoIds = List<String>.from(album.photoIDs)..remove(photoId);

    final updatedAlbum = album.copyWith(photoIDs: updatedPhotoIds);

    _albums[index] = updatedAlbum;
    return updatedAlbum;
  }

  static Future<List<Album>> searchAlbums(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllAlbums();
    }

    return _albums.where((album) {
      final nameMatches = album.name.toLowerCase().contains(normalizedQuery);
      final descriptionMatches =
          album.description?.toLowerCase().contains(normalizedQuery) ?? false;

      return nameMatches || descriptionMatches;
    }).toList();
  }

  static Future<List<Album>> getAlbumsContainingPhoto(String photoId) async {
    return _albums.where((album) => album.photoIDs.contains(photoId)).toList();
  }
}
