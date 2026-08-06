import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/photo_provider.dart';
import '../services/photo_service.dart';
import '../widgets/server_photo_image.dart';

enum ExploreViewMode { photos, albums, mixed }
enum ExploreSearchType { global, name, caption, category, time, comments }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ExploreViewMode _viewMode = ExploreViewMode.photos;
  String _query = '';
  ExploreSearchType _searchType = ExploreSearchType.global;
  List<Photo>? _searchResults;
  bool _isSearching = false;
  int _searchRequest = 0;

  final ScrollController _scrollController = ScrollController();
  bool _searchVisible = true;
  double _lastOffset = 0;
  static const double _deltaThreshold = 20;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PhotoProvider>().loadPhotos();
      context.read<AlbumProvider>().loadAlbums();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.position.pixels;
    final delta = offset - _lastOffset;

    if (delta.abs() < _deltaThreshold) {
      // ignore tiny moves
      return;
    }

    if (delta > 0 && _searchVisible) {
      // scrolled down -> hide search
      setState(() => _searchVisible = false);
    } else if (delta < 0 && !_searchVisible) {
      // scrolled up -> show search
      setState(() => _searchVisible = true);
    }

    _lastOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();
    final albumProvider = context.watch<AlbumProvider>();

    final photos = (_searchResults ?? photoProvider.photos)
        .where((photo) => photo.isPublic)
        .toList();

    final albums = albumProvider
        .getPublicAlbums()
        .where((album) => _query.isEmpty || _searchType == ExploreSearchType.global)
        .where((album) => _matchesAlbumQuery(album))
        .toList();

    const double searchMaxHeight = 80;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore'), centerTitle: true),
      body: Stack(
        children: [
          Positioned.fill(child: _buildContentWithController(photos, albums)),
          Positioned(
            left: 0,
            right: 0,
            //top: MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: ConstrainedBox(
                      constraints: _searchVisible
                          ? BoxConstraints(maxHeight: searchMaxHeight)
                          : const BoxConstraints(maxHeight: 0),
                      child: Opacity(
                        opacity: _searchVisible ? 1 : 0,
                        child: _buildSearchBarTransparent(),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white.withValues(alpha: 0.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _buildToggleAppleStyle(),
                ),
                if (_isSearching) const LinearProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithController(List<Photo> photos, List<Album> albums) {
    if (_viewMode == ExploreViewMode.photos) {
      if (photos.isEmpty) {
        return const Center(child: Text('No public photos found'));
      }
      return MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 3,
        crossAxisSpacing: 2,
        padding: const EdgeInsets.fromLTRB(1, 120, 1, 150),
        itemCount: photos.length,
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
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 120, 12, 150),
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
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 120, 12, 150),
      itemCount: mixedItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = mixedItems[index];
        if (item.photo != null) return _ExplorePhotoTile(photo: item.photo!);
        return _ExploreAlbumTile(album: item.album!);
      },
    );
  }

  Widget _buildSearchBarTransparent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        key: const ValueKey('explore_search_field'),
        decoration: InputDecoration(
          hintText: _searchHint(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _buildSearchTypeMenu(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          // make it semi-transparent so content behind is visible
          fillColor: Colors.white.withOpacity(0.9),
        ),
        onChanged: _searchPhotos,
      ),
    );
  }

  Widget _buildSearchTypeMenu() {
    return PopupMenuButton<ExploreSearchType>(
      tooltip: 'Search by',
      icon: const Icon(Icons.tune),
      onSelected: (type) {
        setState(() => _searchType = type);
        _searchPhotos(_query);
      },
      itemBuilder: (_) => ExploreSearchType.values
          .map(
            (type) => PopupMenuItem(
              value: type,
              child: Text(_searchTypeLabel(type)),
            ),
          )
          .toList(),
    );
  }

  String _searchHint() {
    return 'Search by ${_searchTypeLabel(_searchType).toLowerCase()}...';
  }

  String _searchTypeLabel(ExploreSearchType type) {
    switch (type) {
      case ExploreSearchType.global:
        return 'All fields';
      case ExploreSearchType.name:
        return 'Name';
      case ExploreSearchType.caption:
        return 'Caption';
      case ExploreSearchType.category:
        return 'Category';
      case ExploreSearchType.time:
        return 'Date (YYYY-MM-DD)';
      case ExploreSearchType.comments:
        return 'Comment';
    }
  }

  Future<void> _searchPhotos(String value) async {
    final query = value.trim();
    final request = ++_searchRequest;
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _searchResults = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _query = query;
      _isSearching = true;
    });
    try {
      final results = await PhotoService.searchPhotos(
        query,
        type: _searchType.name,
      );
      if (!mounted || request != _searchRequest) return;
      setState(() => _searchResults = results);
    } catch (_) {
      if (!mounted || request != _searchRequest) return;
      setState(() => _searchResults = const []);
    } finally {
      if (mounted && request == _searchRequest) {
        setState(() => _isSearching = false);
      }
    }
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

  Widget _buildToggleAppleStyle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _appleSegment("Photos", ExploreViewMode.photos),
              _appleSegment("Albums", ExploreViewMode.albums),
              _appleSegment("Mixed", ExploreViewMode.mixed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appleSegment(String title, ExploreViewMode mode) {
    final selected = _viewMode == mode;

    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          child: Text(title),
        ),
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
            //width: double.infinity,
            //height: double.infinity,
            aspectRatio: photo.aspectRatio,
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
      aspectRatio: photo.aspectRatio,
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
