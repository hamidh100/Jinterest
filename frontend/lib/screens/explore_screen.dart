import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/photo_provider.dart';
import '../widgets/server_photo_image.dart';

enum ExploreViewMode { photos, albums, mixed }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ExploreViewMode _viewMode = ExploreViewMode.photos;
  String _query = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PhotoProvider>().loadPhotos();
      context.read<AlbumProvider>().loadAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();
    final albumProvider = context.watch<AlbumProvider>();

    final photos = photoProvider.photos
        .where((photo) => photo.isPublic)
        .where((photo) => _matchesPhotoQuery(photo))
        .toList();

    final albums = albumProvider
        .getPublicAlbums()
        .where((album) => _matchesAlbumQuery(album))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore'), centerTitle: true),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildToggle(),
          Expanded(child: _buildContent(photos, albums)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search public photos and albums...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.tune),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() => _query = value.trim().toLowerCase());
        },
      ),
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<ExploreViewMode>(
        segments: const [
          ButtonSegment(
            value: ExploreViewMode.photos,
            label: Text('Photos'),
            icon: Icon(Icons.image),
          ),
          ButtonSegment(
            value: ExploreViewMode.albums,
            label: Text('Albums'),
            icon: Icon(Icons.photo_album),
          ),
          ButtonSegment(
            value: ExploreViewMode.mixed,
            label: Text('Mixed'),
            icon: Icon(Icons.dashboard),
          ),
        ],
        selected: {_viewMode},
        onSelectionChanged: (selection) {
          setState(() => _viewMode = selection.first);
        },
      ),
    );
  }

  Widget _buildContent(List<Photo> photos, List<Album> albums) {
    if (_viewMode == ExploreViewMode.photos) {
      if (photos.isEmpty) {
        return const Center(child: Text('No public photos found'));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return _ExplorePhotoTile(photo: photos[index]);
        },
      );
    }

    if (_viewMode == ExploreViewMode.albums) {
      if (albums.isEmpty) {
        return const Center(child: Text('No public albums found'));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: albums.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return _ExploreAlbumTile(album: albums[index]);
        },
      );
    }

    final mixedItems = [
      ...photos.map((photo) => _ExploreMixedItem.photo(photo)),
      ...albums.map((album) => _ExploreMixedItem.album(album)),
    ];

    mixedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (mixedItems.isEmpty) {
      return const Center(child: Text('No public media found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: mixedItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = mixedItems[index];

        if (item.photo != null) {
          return _ExplorePhotoTile(photo: item.photo!);
        }

        return _ExploreAlbumTile(album: item.album!);
      },
    );
  }

  bool _matchesPhotoQuery(Photo photo) {
    if (_query.isEmpty) return true;

    final nameMatches = photo.name.toLowerCase().contains(_query);
    final captionMatches =
        photo.captionText?.toLowerCase().contains(_query) ?? false;
    final tagMatches = photo.categoryList.any(
      (tag) => tag.toLowerCase().contains(_query),
    );

    return nameMatches || captionMatches || tagMatches;
  }

  bool _matchesAlbumQuery(Album album) {
    if (_query.isEmpty) return true;

    final nameMatches = album.name.toLowerCase().contains(_query);
    final descriptionMatches =
        album.description?.toLowerCase().contains(_query) ?? false;

    return nameMatches || descriptionMatches;
  }
}

class _ExplorePhotoTile extends StatelessWidget {
  final Photo photo;

  const _ExplorePhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/photo-details', arguments: photo.uuid);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: Colors.grey,
          child: ServerPhotoImage(
            photoId: photo.uuid,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ExploreAlbumTile extends StatelessWidget {
  final Album album;

  const _ExploreAlbumTile({required this.album});

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();

    final albumPhotos = photoProvider.photos
        .where((photo) => album.photoIDs.contains(photo.uuid))
        .where((photo) => photo.isPublic)
        .toList();

    final coverPhoto = albumPhotos.isNotEmpty ? albumPhotos.last : null;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/album-details', arguments: album.uuid);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.deepPurple.shade100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (coverPhoto != null)
                _buildCover(coverPhoto)
              else
                const Center(
                  child: Icon(
                    Icons.photo_album,
                    size: 56,
                    color: Colors.deepPurple,
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ColoredBox(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            album.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${album.photoIDs.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(Photo photo) {
    return ServerPhotoImage(
      photoId: photo.uuid,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

class _ExploreMixedItem {
  final Photo? photo;
  final Album? album;
  final DateTime createdAt;

  _ExploreMixedItem.photo(Photo this.photo)
    : album = null,
      createdAt = photo.photoAge;

  _ExploreMixedItem.album(Album this.album)
    : photo = null,
      createdAt = album.albumAge;
}
