import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';

class AlbumDetailsScreen extends StatelessWidget {
  final String albumId;

  const AlbumDetailsScreen({super.key, required this.albumId});

  @override
  Widget build(BuildContext context) {
    final albumProvider = context.watch<AlbumProvider>();
    final photoProvider = context.watch<PhotoProvider>();
    final authProvider = context.watch<AuthProvider>();

    final currentUser = authProvider.currentUser;
    final album = albumProvider.getAlbumById(albumId);

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

    final albumPhotos = photoProvider.photos
        .where((photo) => album.photoIDs.contains(photo.uuid))
        .where((photo) => isOwner || photo.isPublic)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(album.name),
        centerTitle: true,
        actions: [
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
            _buildAlbumHeader(album, albumPhotos.length),
            const Divider(height: 32),
            _buildPhotosGrid(context, album, albumPhotos, isOwner),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumHeader(Album album, int photoCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            album.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            album.description?.trim().isNotEmpty == true
                ? album.description!
                : 'No description',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AlbumInfoChip(
                icon: album.isPublic ? Icons.public : Icons.lock_outline,
                label: album.isPublic ? 'Public' : 'Private',
              ),
              _AlbumInfoChip(
                icon: Icons.photo_library_outlined,
                label: '$photoCount ${photoCount == 1 ? 'photo' : 'photos'}',
              ),
              _AlbumInfoChip(
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
      padding: const EdgeInsets.all(12),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Album deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = context.read<AlbumProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Delete failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
    final file = File(photo.path);

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
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: file.existsSync()
                  ? Image.file(file, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          photo.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
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

class _AlbumInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AlbumInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
