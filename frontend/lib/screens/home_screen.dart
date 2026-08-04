import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../widgets/server_photo_image.dart';
import 'explore_screen.dart';
import 'likes_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _FeedPage(),
    ExploreScreen(),
    LikesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/upload');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Likes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

enum HomeViewMode { photos, albums, mixed }

class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  HomeViewMode _viewMode = HomeViewMode.photos;
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
    final authProvider = context.watch<AuthProvider>();
    final photoProvider = context.watch<PhotoProvider>();
    final albumProvider = context.watch<AlbumProvider>();

    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('You are not logged in')));
    }

    final userPhotos = photoProvider
        .getUserPhotos(currentUser.uuid)
        .where(_matchesPhotoQuery)
        .toList();

    final userAlbums = albumProvider
        .getUserAlbums(currentUser.uuid)
        .where(_matchesAlbumQuery)
        .toList();

    final isLoading = photoProvider.isLoading || albumProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildViewToggle(),
          if (isLoading) const LinearProgressIndicator(),
          Expanded(child: _buildContent(userPhotos, userAlbums)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your media...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _query = value.trim().toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<HomeViewMode>(
        segments: const [
          ButtonSegment(
            value: HomeViewMode.photos,
            label: Text('Photos'),
            icon: Icon(Icons.image),
          ),
          ButtonSegment(
            value: HomeViewMode.albums,
            label: Text('Albums'),
            icon: Icon(Icons.photo_album),
          ),
          ButtonSegment(
            value: HomeViewMode.mixed,
            label: Text('Mixed'),
            icon: Icon(Icons.dashboard),
          ),
        ],
        selected: {_viewMode},
        onSelectionChanged: (selection) {
          setState(() {
            _viewMode = selection.first;
          });
        },
      ),
    );
  }

  Widget _buildContent(List<Photo> photos, List<Album> albums) {
    switch (_viewMode) {
      case HomeViewMode.photos:
        if (photos.isEmpty) {
          return const _EmptyState(
            icon: Icons.image_outlined,
            text: 'No photos found',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return _PhotoCard(photo: photos[index]);
          },
        );

      case HomeViewMode.albums:
        if (albums.isEmpty) {
          return const _EmptyState(
            icon: Icons.photo_album_outlined,
            text: 'No albums found',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            return _AlbumCard(album: albums[index]);
          },
        );

      case HomeViewMode.mixed:
        final mixedItems = [
          ...photos.map((photo) => _MixedMediaItem.photo(photo)),
          ...albums.map((album) => _MixedMediaItem.album(album)),
        ];

        mixedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (mixedItems.isEmpty) {
          return const _EmptyState(
            icon: Icons.dashboard_outlined,
            text: 'No media found',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: mixedItems.length,
          itemBuilder: (context, index) {
            final item = mixedItems[index];

            if (item.photo != null) {
              return _PhotoCard(photo: item.photo!);
            }

            return _AlbumCard(album: item.album!);
          },
        );
    }
  }

  bool _matchesPhotoQuery(Photo photo) {
    if (_query.isEmpty) return true;

    final nameMatches = photo.name.toLowerCase().contains(_query);
    final captionMatches =
        photo.captionText?.toLowerCase().contains(_query) ?? false;
    final categoryMatches = photo.categoryList.any(
      (category) => category.toLowerCase().contains(_query),
    );

    return nameMatches || captionMatches || categoryMatches;
  }

  bool _matchesAlbumQuery(Album album) {
    if (_query.isEmpty) return true;

    final nameMatches = album.name.toLowerCase().contains(_query);
    final descriptionMatches =
        album.description?.toLowerCase().contains(_query) ?? false;

    return nameMatches || descriptionMatches;
  }
}

class _MixedMediaItem {
  final Photo? photo;
  final Album? album;
  final DateTime createdAt;

  _MixedMediaItem.photo(Photo this.photo)
    : album = null,
      createdAt = photo.photoAge;

  _MixedMediaItem.album(Album this.album)
    : photo = null,
      createdAt = album.albumAge;
}

class _PhotoCard extends StatelessWidget {
  final Photo photo;

  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isLiked =
        currentUser != null && photo.likeIDs.contains(currentUser.uuid);

    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/photo-details',
                arguments: photo.uuid,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhotoHeader(photo: photo),
                _PhotoImage(photo: photo),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: currentUser == null
                      ? null
                      : () {
                          context.read<PhotoProvider>().toggleLike(
                            photoId: photo.uuid,
                            userId: currentUser.uuid,
                          );
                        },
                ),
                Text('${photo.likeIDs.length}'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment feature coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                Text('${photo.commentIDs.length}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (photo.captionText != null && photo.captionText!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                photo.captionText!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          if (photo.categoryList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: photo.categoryList.map((category) {
                  return Chip(
                    label: Text(category),
                    backgroundColor: Colors.deepPurple[100],
                    labelStyle: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  final Photo photo;

  const _PhotoHeader({required this.photo});

  @override
  Widget build(BuildContext context) {
    final ownerLabel = photo.ownerID.isNotEmpty ? photo.ownerID[0] : '?';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text(
              ownerLabel.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${photo.ownerID}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _timeAgo(photo.photoAge),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoImage extends StatelessWidget {
  final Photo photo;

  const _PhotoImage({required this.photo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: ColoredBox(
        color: Colors.grey,
        child: ServerPhotoImage(
          photoId: photo.uuid,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final Album album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();

    final albumPhotos = photoProvider.photos
        .where((photo) => album.photoIDs.contains(photo.uuid))
        .toList();

    final coverPhoto = albumPhotos.isNotEmpty ? albumPhotos.first : null;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/album-details', arguments: album.uuid);
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: coverPhoto == null
                  ? Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.photo_album,
                        size: 56,
                        color: Colors.grey,
                      ),
                    )
                  : _AlbumCoverImage(photo: coverPhoto),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      album.description?.trim().isNotEmpty == true
                          ? album.description!
                          : 'No description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${album.photoIDs.length} ${album.photoIDs.length == 1 ? 'photo' : 'photos'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCoverImage extends StatelessWidget {
  final Photo photo;

  const _AlbumCoverImage({required this.photo});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey,
      child: ServerPhotoImage(
        photoId: photo.uuid,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  }

  if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  }

  if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  }

  return 'Just now';
}
