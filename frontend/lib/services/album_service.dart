import '../exceptions/exceptions.dart';
import '../models/album.dart';
import 'api_client.dart';

class AlbumService {
  static Future<List<Album>> getAllAlbums() async {
    final response = await ApiClient.instance.send(
      method: 'GET',
      route: '/albums',
    );
    return _albumListFromResponse(response);
  }

  static Future<List<Album>> getAlbumsByOwner(String ownerId) async {
    final albums = await getAllAlbums();
    return albums.where((album) => album.ownerID == ownerId).toList();
  }

  static Future<List<Album>> getPublicAlbums() => getAllAlbums();

  static Future<Album?> getAlbumById(String albumId) async {
    try {
      final response = await ApiClient.instance.send(
        method: 'GET',
        route: '/albums/$albumId',
      );
      return _albumFromPayload(response);
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      return null;
    }
  }

  static Future<Album> createAlbum(Album album) async {
    final response = await ApiClient.instance.send(
      method: 'POST',
      route: '/albums',
      payload: {
        'ownerId': album.ownerID,
        'name': album.name,
        'description': album.description,
        'isPublic': album.isPublic,
        'photoIds': album.photoIDs,
      },
    );
    return _albumFromPayload(response);
  }

  static Future<void> deleteAlbum(String albumId) async {
    await ApiClient.instance.send(method: 'DELETE', route: '/albums/$albumId');
  }

  static Future<Album> updateAlbum(Album album) => _updateAlbum(album);

  static Future<Album?> addPhotoToAlbum({
    required String albumId,
    required String photoId,
  }) async {
    final album = await getAlbumById(albumId);
    if (album == null) return null;
    if (album.photoIDs.contains(photoId)) return album;
    return _updateAlbum(album.copyWith(photoIDs: [...album.photoIDs, photoId]));
  }

  static Future<Album?> removePhotoFromAlbum({
    required String albumId,
    required String photoId,
  }) async {
    final album = await getAlbumById(albumId);
    if (album == null) return null;
    return _updateAlbum(
      album.copyWith(
        photoIDs: album.photoIDs.where((id) => id != photoId).toList(),
      ),
    );
  }

  static Future<List<Album>> searchAlbums(String query) async {
    final albums = await getAllAlbums();
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return albums;
    return albums.where((album) {
      return album.name.toLowerCase().contains(normalizedQuery) ||
          (album.description?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();
  }

  static Future<List<Album>> getAlbumsContainingPhoto(String photoId) async {
    final albums = await getAllAlbums();
    return albums.where((album) => album.photoIDs.contains(photoId)).toList();
  }

  static Future<Album> _updateAlbum(Album album) async {
    final response = await ApiClient.instance.send(
      method: 'PUT',
      route: '/albums/${album.uuid}',
      payload: {
        'name': album.name,
        'description': album.description,
        'isPublic': album.isPublic,
        'photoIds': album.photoIDs,
      },
    );
    return _albumFromPayload(response);
  }

  static List<Album> _albumListFromResponse(Map<String, dynamic> response) {
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> || payload['albums'] is! List) {
      throw StateError('Server returned an invalid album list');
    }
    return (payload['albums'] as List)
        .whereType<Map<String, dynamic>>()
        .map(_albumFromJson)
        .toList();
  }

  static Album _albumFromPayload(Map<String, dynamic> response) {
    final payload = response['payload'];
    if (payload is! Map<String, dynamic> ||
        payload['album'] is! Map<String, dynamic>) {
      throw StateError('Server returned an invalid album');
    }
    return _albumFromJson(payload['album'] as Map<String, dynamic>);
  }

  static Album _albumFromJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List? ?? const [];
    return Album(
      uuid: json['id']?.toString() ?? '',
      ownerID: json['ownerId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Album',
      description: json['description']?.toString(),
      photoIDs: photos
          .whereType<Map<String, dynamic>>()
          .map((photo) => photo['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList(),
      albumAge:
          DateTime.tryParse(json['albumAge']?.toString() ?? '') ??
          DateTime.now(),
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }
}
