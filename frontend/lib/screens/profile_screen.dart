import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../models/user.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/server_photo_image.dart';

enum ProfileViewMode { photos, albums }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileViewMode _viewMode = ProfileViewMode.photos;
  User? _editedUser;

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

    final authUser = authProvider.currentUser;

    if (authUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final user = _editedUser?.uuid == authUser.uuid ? _editedUser! : authUser;

    final followersCount = user.followerIDs.length;
    final followingCount = user.followingIDs.length;

    final userPhotos = photoProvider.getUserPhotos(user.uuid);
    final userAlbums = albumProvider.getUserAlbums(user.uuid);

    final isLoading = photoProvider.isLoading || albumProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        actions: [
          _buildThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context, authProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await photoProvider.loadPhotos();
          await albumProvider.loadAlbums();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(
                fullname: user.fullname,
                username: user.username,
                contact: user.email ?? user.phone ?? 'No contact info',
              ),

              _buildStatsRow(
                followersCount: followersCount,
                followingCount: followingCount,
                postsCount: userPhotos.length,
                albumsCount: userAlbums.length,
              ),

              const Divider(height: 32),

              _buildEditProfileButton(context),

              const SizedBox(height: 20),

              _buildViewToggle(),

              if (isLoading) const LinearProgressIndicator(),

              const SizedBox(height: 16),

              if (_viewMode == ProfileViewMode.photos)
                _buildPhotosSection(userPhotos)
              else
                _buildAlbumsSection(userAlbums),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the app bar button that switches between light and dark mode.
  Widget _buildThemeToggleButton() {
    final themeProvider = context.watch<ThemeProvider>();

    return IconButton(
      tooltip: themeProvider.isDarkMode ? 'Light mode' : 'Dark mode',
      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: themeProvider.toggleTheme,
    );
  }

  Widget _buildProfileHeader({
    required String fullname,
    required String? username,
    required String contact,
  }) {
    final firstLetter = fullname.trim().isNotEmpty
        ? fullname.trim()[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple,
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            fullname.isEmpty ? 'Unknown User' : fullname,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          Text(
            username == null ? '@unknown' : '@$username',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 8),

          Text(contact, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required int followersCount,
    required int followingCount,
    required int postsCount,
    required int albumsCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Followers', value: '$followersCount'),
          _StatItem(label: 'Following', value: '$followingCount'),
          _StatItem(label: 'Photos', value: '$postsCount'),
          _StatItem(label: 'Albums', value: '$albumsCount'),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    final authUser = context.read<AuthProvider>().currentUser;
    final user = authUser == null
        ? null
        : _editedUser?.uuid == authUser.uuid
        ? _editedUser!
        : authUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: Colors.deepPurple,
        ),
        onPressed: user == null
            ? null
            : () async {
                final updatedUser = await Navigator.push<User>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _EditProfileScreen(user: user),
                  ),
                );

                if (updatedUser == null || !context.mounted) return;

                context.read<AuthProvider>().updateCurrentUser(updatedUser);

                setState(() {
                  _editedUser = updatedUser;
                });

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile saved.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
        child: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SegmentedButton<ProfileViewMode>(
        segments: const [
          ButtonSegment(
            value: ProfileViewMode.photos,
            icon: Icon(Icons.image),
            label: Text('Photos'),
          ),
          ButtonSegment(
            value: ProfileViewMode.albums,
            icon: Icon(Icons.photo_album),
            label: Text('Albums'),
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

  Widget _buildPhotosSection(List<Photo> photos) {
    if (photos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(Icons.image, size: 80, color: Colors.grey),
            SizedBox(height: 8),
            Text('No posts yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        itemCount: photos.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (context, index) {
          return _ProfilePhotoTile(photo: photos[index]);
        },
      ),
    );
  }

  Widget _buildAlbumsSection(List<Album> albums) {
    if (albums.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(Icons.photo_album, size: 80, color: Colors.grey),
            SizedBox(height: 8),
            Text('No albums yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: albums.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        return _ProfileAlbumTile(album: albums[index]);
      },
    );
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}

class _EditProfileScreen extends StatefulWidget {
  final User user;

  const _EditProfileScreen({required this.user});

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullnameController;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.user.fullname);
    _usernameController = TextEditingController(
      text: widget.user.username ?? '',
    );
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // Validates the form and returns the updated user to the profile screen.
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final fullname = _fullnameController.text.trim();
    final username = _usernameController.text.trim();

    try {
      final updatedUser = await UserService.updateUser(
        user: widget.user,
        username: username,
        fullname: fullname,
      );

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Returns the read-only contact text shown in the edit form.
  String get _contact {
    return widget.user.email ?? widget.user.phone ?? 'No contact info';
  }

  // Checks whether the user changed any editable profile field.
  bool get _hasChanges {
    return _fullnameController.text.trim() != widget.user.fullname ||
        _usernameController.text.trim() != (widget.user.username ?? '');
  }

  // Refreshes the save button and avatar preview when text changes.
  void _refreshSaveButton() {
    setState(() {});
  }

  // Saves the form when the username field submits from the keyboard.
  void _submitFromKeyboard(String _) {
    _handleSave();
  }

  // Validates the full name field before saving.
  String? _validateFullname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  // Validates the username field before saving.
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  // Builds the avatar preview from the current full name.
  Widget _buildAvatar(String firstLetter) {
    return Center(
      child: CircleAvatar(
        radius: 48,
        backgroundColor: Colors.deepPurple,
        child: Text(
          firstLetter,
          style: const TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullname = _fullnameController.text.trim();
    final firstLetter = fullname.isNotEmpty ? fullname[0].toUpperCase() : '?';

    // Main edit profile page layout.
    return Scaffold(
      // Top bar for the edit profile page.
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      // Scrollable page body so the form fits on small screens.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        // Groups all editable profile fields for validation.
        child: Form(
          key: _formKey,
          // Stacks the avatar, fields, and save button vertically.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shows a live avatar preview from the full name.
              _buildAvatar(firstLetter),
              const SizedBox(height: 28),
              // Full name input box.
              TextFormField(
                controller: _fullnameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (_) => _refreshSaveButton(),
                validator: _validateFullname,
              ),
              const SizedBox(height: 16),
              // Username input box.
              TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _submitFromKeyboard,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (_) => _refreshSaveButton(),
                validator: _validateUsername,
              ),
              const SizedBox(height: 16),
              // Read-only contact box.
              TextFormField(
                initialValue: _contact,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  prefixIcon: const Icon(Icons.mail_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Save button for submitting valid profile changes.
              ElevatedButton(
                onPressed: _hasChanges ? _handleSave : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePhotoTile extends StatelessWidget {
  final Photo photo;

  const _ProfilePhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/photo-details', arguments: photo.uuid);
      },
      child: ColoredBox(
        color: Colors.grey,
        child: ServerPhotoImage(
          photoId: photo.uuid,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ProfileAlbumTile extends StatelessWidget {
  final Album album;

  const _ProfileAlbumTile({required this.album});

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();

    final albumPhotos = photoProvider.photos
        .where((photo) => album.photoIDs.contains(photo.uuid))
        .toList();

    final coverPhoto = albumPhotos.isNotEmpty ? albumPhotos.first : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/album-details', arguments: album.uuid);
        },
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: coverPhoto == null
                  ? Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.photo_album,
                        size: 48,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      album.description?.trim().isNotEmpty == true
                          ? album.description!
                          : 'No description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${album.photoIDs.length} ${album.photoIDs.length == 1 ? 'photo' : 'photos'}',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
