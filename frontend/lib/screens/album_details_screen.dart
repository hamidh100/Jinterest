import 'package:flutter/material.dart';
import 'package:jinterest/widgets/uploader_tile.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../providers/snackbar_fab_provider.dart';
import '../widgets/info_chip.dart';
import '../widgets/create_album_dialog.dart';
import '../widgets/server_photo_image.dart';

class AlbumDetailsScreen extends StatefulWidget {
  final String albumId;

  const AlbumDetailsScreen({super.key, required this.albumId});

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

enum AlbumPhotoOrder { newest, oldest, mostLiked, name }

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  AlbumPhotoOrder _photoOrder = AlbumPhotoOrder.newest;

  @override
  Widget build(BuildContext context) {
    final albumProvider = context.watch<AlbumProvider>();
    final photoProvider = context.watch<PhotoProvider>();
    final authProvider = context.watch<AuthProvider>();

    final currentUser = authProvider.currentUser;
    final album = albumProvider.getAlbumById(widget.albumId);

    if (album == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Album Details')),
        body: const Center(child: Text('Album not found')),
      );
    }

    final isOwner = currentUser != null && currentUser.uuid == album.ownerID;

    if (!album.isPublic && !isOwner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Private Album'), centerTitle: true),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This album is private.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final albumPhotos = _sortPhotos(
      photoProvider.photos
          .where((photo) => album.photoIDs.contains(photo.uuid))
          .where((photo) => isOwner || photo.isPublic)
          .toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Album'),
        centerTitle: true,
        actions: [
          PopupMenuButton<AlbumPhotoOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort photos',
            onSelected: (order) => setState(() => _photoOrder = order),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: AlbumPhotoOrder.newest,
                child: Text('Newest first'),
              ),
              PopupMenuItem(
                value: AlbumPhotoOrder.oldest,
                child: Text('Oldest first'),
              ),
              PopupMenuItem(
                value: AlbumPhotoOrder.mostLiked,
                child: Text('Most liked'),
              ),
              PopupMenuItem(value: AlbumPhotoOrder.name, child: Text('Name')),
            ],
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editAlbum(context, album),
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteAlbum(context, album),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAlbumHeader(context, album, albumPhotos.length),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: const Divider(height: 32),
            ),
            _buildPhotosGrid(context, album, albumPhotos, isOwner),
          ],
        ),
      ),
    );
  }

  List<Photo> _sortPhotos(List<Photo> photos) {
    switch (_photoOrder) {
      case AlbumPhotoOrder.newest:
        photos.sort(
          (first, second) => second.photoAge.compareTo(first.photoAge),
        );
      case AlbumPhotoOrder.oldest:
        photos.sort(
          (first, second) => first.photoAge.compareTo(second.photoAge),
        );
      case AlbumPhotoOrder.mostLiked:
        photos.sort(
          (first, second) =>
              second.likeIDs.length.compareTo(first.likeIDs.length),
        );
      case AlbumPhotoOrder.name:
        photos.sort(
          (first, second) =>
              first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        );
    }
    return photos;
  }

  Future<void> _editAlbum(BuildContext context, Album album) async {
    final editedAlbum = await showEditAlbumDialog(
      context: context,
      album: album,
    );

    if (editedAlbum == null || !context.mounted) return;

    final success = await context.read<AlbumProvider>().updateAlbum(
      editedAlbum,
    );

    if (!context.mounted) return;

    final message = success
        ? 'Album updated'
        : context.read<AlbumProvider>().errorMessage ?? 'Update failed';

    context.read<SnackbarFabProvider>().showSnackBar(
      context,
      SnackBar(
        content: Text(message),
        backgroundColor: success ? null : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAlbumHeader(BuildContext context, Album album, int photoCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            album.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          UploaderTile(ownerID: album.ownerID, padding: EdgeInsets.zero),
          const SizedBox(height: 14),
          Text(
            album.description?.trim().isNotEmpty == true
                ? album.description!
                : 'No description',
            style: TextStyle(
              fontSize: 16,
              color: album.description?.trim().isNotEmpty == true
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.45),
              height: 1.35,
            ),
          ),
          const Divider(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              InfoChip(
                icon: album.isPublic ? Icons.public : Icons.lock_outline,
                label: album.isPublic ? 'Public' : 'Private',
              ),
              InfoChip(
                icon: Icons.photo_library_outlined,
                label: '$photoCount ${photoCount == 1 ? 'photo' : 'photos'}',
              ),
              InfoChip(
                icon: Icons.calendar_today_outlined,
                label:
                    '${album.albumAge.year}/${album.albumAge.month.toString().padLeft(2, '0')}/${album.albumAge.day.toString().padLeft(2, '0')} ${album.albumAge.hour.toString().padLeft(2, '0')}:${album.albumAge.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid(
    BuildContext context,
    Album album,
    List<Photo> photos,
    bool isOwner,
  ) {
    if (photos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No photos in this album yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];

        return _AlbumPhotoTile(album: album, photo: photo, isOwner: isOwner);
      },
    );
  }

  Future<void> _confirmDeleteAlbum(BuildContext context, Album album) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete album?'),
          content: const Text(
            'This will delete the album, but photos will remain in your library.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final success = await context.read<AlbumProvider>().deleteAlbum(album.uuid);

    if (!context.mounted) return;

    if (success) {
      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text('Album deleted'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } else {
      final error = context.read<AlbumProvider>().errorMessage;
      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text(error ?? 'Delete failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _AlbumPhotoTile extends StatelessWidget {
  final Album album;
  final Photo photo;
  final bool isOwner;

  const _AlbumPhotoTile({
    required this.album,
    required this.photo,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/photo-details',
              arguments: photo.uuid,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: Colors.grey,
              child: ServerPhotoImage(photoId: photo.uuid, fit: BoxFit.cover),
            ),
          ),
        ),
        if (isOwner)
          Positioned(
            top: 4,
            right: 4,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.read<AlbumProvider>().removePhotoFromAlbum(
                    albumId: album.uuid,
                    photoId: photo.uuid,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
