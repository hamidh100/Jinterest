import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../providers/snackbar_fab_provider.dart';
import '../theme/app_palette.dart';
import '../services/photo_service.dart';
import '../widgets/photo_search_field.dart';
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
    final snackbarFabProvider = context.watch<SnackbarFabProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final compactNavigationBar = snackbarFabProvider.compactNavigationBar;
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      floatingActionButton: snackbarFabProvider.showHomeFab
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upload');
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add_a_photo, color: Colors.white),
            )
          : null,
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            compactNavigationBar ? 2 : 12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: compactNavigationBar ? 56 : 70,
                indicatorColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .25),

                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  return TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white : null,
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w600
                        : FontWeight.w500,
                  );
                }),
                iconTheme: WidgetStatePropertyAll(
                  IconThemeData(color: isDarkMode ? Colors.white : null),
                ),
              ),
              child: NavigationBar(
                backgroundColor:
                    (isDarkMode ? AppPalette.surface : Colors.white).withValues(
                      alpha: .80,
                    ),
                elevation: 0,
                labelBehavior: compactNavigationBar
                    ? NavigationDestinationLabelBehavior.alwaysHide
                    : NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) {
                  if (i != 1)
                    snackbarFabProvider.setNavigationBarCompact(false);
                  setState(() => _selectedIndex = i);
                },
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.favorite_outline),
                    selectedIcon: Icon(Icons.favorite),
                    label: 'Likes',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum HomeViewMode { photos, albums, mixed }

enum HomeSortOrder { newest, oldest, name, mostLiked }

enum HomeFeedSource { mine, following }

class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  HomeViewMode _viewMode = HomeViewMode.photos;
  HomeFeedSource _feedSource = HomeFeedSource.mine;
  HomeSortOrder _sortOrder = HomeSortOrder.newest;
  String _query = '';
  PhotoSearchType _searchType = PhotoSearchType.global;
  List<Photo>? _searchResults;
  bool _isSearching = false;
  int _searchRequest = 0;

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

    final visibleOwnerIds = _feedSource == HomeFeedSource.mine
        ? {currentUser.uuid}
        : currentUser.followingIDs.toSet();

    final userPhotos = (_searchResults ?? photoProvider.photos)
        .where((photo) => visibleOwnerIds.contains(photo.ownerID))
        .where((photo) => _feedSource == HomeFeedSource.mine || photo.isPublic)
        .toList();
    _sortPhotos(userPhotos);

    final userAlbums = albumProvider.albums
        .where((album) => visibleOwnerIds.contains(album.ownerID))
        .where((album) => _feedSource == HomeFeedSource.mine || album.isPublic)
        .where(
          (album) => _query.isEmpty || _searchType == PhotoSearchType.global,
        )
        .where(_matchesAlbumQuery)
        .toList();
    _sortAlbums(userAlbums);

    final isLoading =
        photoProvider.isLoading || albumProvider.isLoading || _isSearching;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<HomeFeedSource>(
          tooltip: 'Choose feed',
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          color: (isDarkMode ? AppPalette.surface : Colors.white).withValues(
            alpha: .80,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          constraints: const BoxConstraints.tightFor(width: 140),
          onSelected: (source) => setState(() => _feedSource = source),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: HomeFeedSource.mine,
              child: Center(
                child: Text(
                  'Your media',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            PopupMenuItem(
              value: HomeFeedSource.following,
              child: Center(
                child: Text(
                  'Following',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          child: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Home',
                  style: TextStyle(color: isDarkMode ? Colors.white : null),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: isDarkMode ? Colors.white : null,
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [_buildSortMenu()],
      ),
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
    return PhotoSearchField(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      fillColor: Colors.grey[100],
      searchType: _searchType,
      onTypeChanged: (type) {
        setState(() => _searchType = type);
        _searchPhotos(_query);
      },
      onChanged: _searchPhotos,
    );
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
        type: _searchType.apiValue,
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

  Widget _buildSortMenu() {
    return PopupMenuButton<HomeSortOrder>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort media',
      onSelected: (order) => setState(() => _sortOrder = order),
      itemBuilder: (_) => const [
        PopupMenuItem(value: HomeSortOrder.newest, child: Text('Newest first')),
        PopupMenuItem(value: HomeSortOrder.oldest, child: Text('Oldest first')),
        PopupMenuItem(value: HomeSortOrder.name, child: Text('Name')),
        PopupMenuItem(
          value: HomeSortOrder.mostLiked,
          child: Text('Most liked'),
        ),
      ],
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
          padding: const EdgeInsets.only(bottom: 150),
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
          padding: const EdgeInsets.only(bottom: 150),
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

        _sortMixedItems(mixedItems);

        if (mixedItems.isEmpty) {
          return const _EmptyState(
            icon: Icons.dashboard_outlined,
            text: 'No media found',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 150),
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

  bool _matchesAlbumQuery(Album album) {
    if (_query.isEmpty) return true;
    final query = _query.toLowerCase();

    final nameMatches = album.name.toLowerCase().contains(query);
    final descriptionMatches =
        album.description?.toLowerCase().contains(query) ?? false;

    return nameMatches || descriptionMatches;
  }

  void _sortPhotos(List<Photo> photos) {
    switch (_sortOrder) {
      case HomeSortOrder.newest:
        photos.sort(
          (first, second) => second.photoAge.compareTo(first.photoAge),
        );
      case HomeSortOrder.oldest:
        photos.sort(
          (first, second) => first.photoAge.compareTo(second.photoAge),
        );
      case HomeSortOrder.name:
        photos.sort(
          (first, second) =>
              first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        );
      case HomeSortOrder.mostLiked:
        photos.sort(
          (first, second) =>
              second.likeIDs.length.compareTo(first.likeIDs.length),
        );
    }
  }

  void _sortAlbums(List<Album> albums) {
    if (_sortOrder == HomeSortOrder.name) {
      albums.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );
      return;
    }

    albums.sort(
      (first, second) => _sortOrder == HomeSortOrder.oldest
          ? first.albumAge.compareTo(second.albumAge)
          : second.albumAge.compareTo(first.albumAge),
    );
  }

  void _sortMixedItems(List<_MixedMediaItem> items) {
    switch (_sortOrder) {
      case HomeSortOrder.newest:
        items.sort(
          (first, second) => second.createdAt.compareTo(first.createdAt),
        );
      case HomeSortOrder.oldest:
        items.sort(
          (first, second) => first.createdAt.compareTo(second.createdAt),
        );
      case HomeSortOrder.name:
        items.sort(
          (first, second) =>
              first.name.toLowerCase().compareTo(second.name.toLowerCase()),
        );
      case HomeSortOrder.mostLiked:
        items.sort(
          (first, second) => second.likeCount.compareTo(first.likeCount),
        );
    }
  }
}

class _MixedMediaItem {
  final Photo? photo;
  final Album? album;
  final DateTime createdAt;

  String get name => photo?.name ?? album!.name;

  int get likeCount => photo?.likeIDs.length ?? 0;

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
            child: _PhotoImage(photo: photo),
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
                    Navigator.pushNamed(
                      context,
                      '/photo-details',
                      arguments: photo.uuid,
                    );
                  },
                ),
                Text('${photo.commentIDs.length}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    context.read<SnackbarFabProvider>().showSnackBar(
                      context,
                      SnackBar(
                        content: const Text('Share feature coming soon'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
            backgroundColor: Theme.of(context).colorScheme.primary,
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
          aspectRatio: photo.aspectRatio,
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
        aspectRatio: photo.aspectRatio,
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
