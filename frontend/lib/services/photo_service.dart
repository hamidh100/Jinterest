import '../models/photo.dart';

class PhotoService {
  static final List<Photo> _photos = [];

  static Future<List<Photo>> getAllPhotos() async {
    return List.unmodifiable(_photos);
  }

  static Future<List<Photo>> getPhotosByOwner(String ownerId) async {
    return _photos.where((photo) => photo.ownerID == ownerId).toList();
  }

  static Future<Photo?> getPhotoById(String photoId) async {
    try {
      return _photos.firstWhere((photo) => photo.uuid == photoId);
    } catch (_) {
      return null;
    }
  }

  static Future<Photo> addPhoto(Photo photo) async {
    _photos.insert(0, photo);
    return photo;
  }

  static Future<void> deletePhoto(String photoId) async {
    _photos.removeWhere((photo) => photo.uuid == photoId);
  }

  static Future<List<Photo>> searchPhotos(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllPhotos();
    }

    return _photos.where((photo) {
      final nameMatches = photo.name.toLowerCase().contains(normalizedQuery);
      final captionMatches =
          photo.captionText?.toLowerCase().contains(normalizedQuery) ?? false;
      final tagMatches = photo.categoryList.any(
        (tag) => tag.toLowerCase().contains(normalizedQuery),
      );

      return nameMatches || captionMatches || tagMatches;
    }).toList();
  }

  static Future<Photo?> toggleLike({
    required String photoId,
    required String userId,
  }) async {
    final index = _photos.indexWhere((photo) => photo.uuid == photoId);

    if (index == -1) {
      return null;
    }

    final oldPhoto = _photos[index];
    final updatedLikes = List<String>.from(oldPhoto.likeIDs);

    if (updatedLikes.contains(userId)) {
      updatedLikes.remove(userId);
    } else {
      updatedLikes.add(userId);
    }

    final updatedPhoto = Photo(
      uuid: oldPhoto.uuid,
      ownerID: oldPhoto.ownerID,
      path: oldPhoto.path,
      name: oldPhoto.name,
      categoryList: oldPhoto.categoryList,
      captionText: oldPhoto.captionText,
      photoAge: oldPhoto.photoAge,
      likeIDs: updatedLikes,
      commentIDs: oldPhoto.commentIDs,
    );

    _photos[index] = updatedPhoto;
    return updatedPhoto;
  }
}
