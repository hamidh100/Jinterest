import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/photo.dart';
import '../models/user.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../providers/snackbar_fab_provider.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../utils/validators.dart';
import '../widgets/follow_button.dart';
import 'followers_screen.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/server_photo_image.dart';
import 'settings_screen.dart';

enum ProfileViewMode { photos, albums }

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileViewMode _viewMode = ProfileViewMode.photos;
  User? _editedUser;
  User? _viewedUser;
  bool _isLoadingUser = false;
  int _profileImageRefreshKey = 0;

  @override
  void initState() {
    super.initState();

    _isLoadingUser = widget.userId != null;

    Future.microtask(() async {
      context.read<PhotoProvider>().loadPhotos();
      context.read<AlbumProvider>().loadAlbums();

      if (widget.userId == null) return;
      try {
        final user = await UserService.getUserById(widget.userId!);
        if (!mounted) return;
        setState(() => _viewedUser = user);
      } catch (_) {
      } finally {
        if (mounted) setState(() => _isLoadingUser = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authProvider = context.watch<AuthProvider>();

    if (_editedUser != authProvider.currentUser) {
      setState(() {
        _profileImageRefreshKey++;
        _editedUser = authProvider.currentUser;
      });
    }
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

    final isOwnProfile =
        widget.userId == null || widget.userId == authUser.uuid;
    final user = isOwnProfile ? authUser : _viewedUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: _isLoadingUser
              ? const CircularProgressIndicator()
              : const Text('User not found'),
        ),
      );
    }

    final userPhotos = photoProvider
        .getUserPhotos(user.uuid)
        .where((photo) => photo.isPublic || photo.ownerID == authUser.uuid)
        .toList();
    final userAlbums = albumProvider
        .getUserAlbums(user.uuid)
        .where((album) => album.isPublic || album.ownerID == authUser.uuid)
        .toList();

    final isLoading = photoProvider.isLoading || albumProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        leading: isOwnProfile
            ? IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              )
            : null,
        actions: [
          _buildThemeToggleButton(),
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmation(context, authProvider),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            photoProvider.loadPhotos(),
            albumProvider.loadAlbums(),
            _refreshProfileUser(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(user: user, isOwnProfile: isOwnProfile),

              _buildStatsRow(
                user: user,
                postsCount: userPhotos.length,
                albumsCount: userAlbums.length,
              ),

              if (!isOwnProfile) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FollowButton(
                    followerId: authUser.uuid,
                    followedId: user.uuid,
                    isFollowing: authUser.followingIDs.contains(user.uuid),
                    width: double.infinity,
                    height: 48,
                    style: FollowButtonStyle.profile,
                    onChanged: (isFollowing) async {
                      await _onProfileFollowChanged(
                        currentUser: authUser,
                        viewedUser: user,
                        isFollowing: isFollowing,
                      );
                    },
                  ),
                ),
              ],

              const Divider(height: 32),

              if (isOwnProfile) ...[
                if (authProvider.isAdmin) ...[
                  Stack(
                    children: [
                      Expanded(child: _buildEditProfileButton(context, 24)),
                      Positioned(
                        left: 24,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/admin'),
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.white,
                            fixedSize: const Size(48, 48),
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else
                  _buildEditProfileButton(context, 24),
                const SizedBox(height: 20),
              ],

              _buildViewToggle(),

              if (isLoading) const LinearProgressIndicator(),

              const SizedBox(height: 16),

              if (_viewMode == ProfileViewMode.photos)
                _buildPhotosSection(userPhotos)
              else
                _buildAlbumsSection(userAlbums),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onProfileFollowChanged({
    required User currentUser,
    required User viewedUser,
    required bool isFollowing,
  }) async {
    final followingIds = List<String>.from(currentUser.followingIDs);
    final followerIds = List<String>.from(viewedUser.followerIDs);
    if (isFollowing) {
      if (!followingIds.contains(viewedUser.uuid)) {
        followingIds.add(viewedUser.uuid);
      }
      if (!followerIds.contains(currentUser.uuid)) {
        followerIds.add(currentUser.uuid);
      }
    } else {
      followingIds.remove(viewedUser.uuid);
      followerIds.remove(currentUser.uuid);
    }
    final updatedCurrentUser = _copyUser(
      currentUser,
      followingIDs: followingIds,
    );
    final updatedViewedUser = _copyUser(viewedUser, followerIDs: followerIds);
    if (!mounted) return;
    await context.read<AuthProvider>().updateCurrentUser(updatedCurrentUser);
    if (!mounted) return;
    setState(() {
      _viewedUser = updatedViewedUser;
    });
  }

  Future<void> _refreshProfileUser() async {
    final authUser = context.read<AuthProvider>().currentUser;
    if (authUser == null) return;
    try {
      if (widget.userId == null || widget.userId == authUser.uuid) {
        UserService.clearUserCache(authUser.uuid);
        UserService.clearProfileImageCache(authUser.uuid);
        final freshUser = await UserService.getUserById(authUser.uuid);
        if (!mounted || freshUser == null) return;
        await context.read<AuthProvider>().updateCurrentUser(freshUser);
      } else {
        UserService.clearUserCache(widget.userId!);
        UserService.clearProfileImageCache(authUser.uuid);
        final freshUser = await UserService.getUserById(widget.userId!);
        if (!mounted || freshUser == null) return;
        setState(() {
          _viewedUser = freshUser;
        });
      }
    } catch (error) {
      debugPrint('Profile refresh failed: $error');
    }
  }

  Widget _buildThemeToggleButton() {
    final themeProvider = context.watch<ThemeProvider>();

    return IconButton(
      tooltip: themeProvider.isDarkMode ? 'Light mode' : 'Dark mode',
      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: themeProvider.toggleTheme,
    );
  }

  Widget _buildProfileHeader({required User user, required bool isOwnProfile}) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ProfileAvatar(
            userId: user.uuid,
            fullname: user.fullname,
            radius: 50,
            imageVersion: _profileImageRefreshKey,
          ),

          const SizedBox(height: 16),

          Text(
            user.fullname.isEmpty ? 'Unknown User' : user.fullname,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          Text(
            user.username == null ? '@unknown' : '@${user.username}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 8),

          Text(
            user.email ?? user.phone ?? 'No contact info',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required User user,
    required int postsCount,
    required int albumsCount,
  }) {
    final authProvider = context.watch<AuthProvider>();
    final authUser = authProvider.currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: 'Followers',
            value: '${user.followerIDs.length}',
            onTap: () => (authUser!.uuid == user.uuid
                ? _openUserList('Followers', user.followerIDs)
                : context.read<SnackbarFabProvider>().showSnackBar(
                    context,
                    SnackBar(
                      content: Text('You can only see your own followers'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  )),
          ),
          _StatItem(
            label: 'Following',
            value: '${user.followingIDs.length}',
            onTap: () => (authUser!.uuid == user.uuid
                ? _openUserList('Following', user.followingIDs)
                : context.read<SnackbarFabProvider>().showSnackBar(
                    context,
                    SnackBar(
                      content: Text('You can only see who you follow'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  )),
          ),
          _StatItem(label: 'Photos', value: '$postsCount'),
          _StatItem(label: 'Albums', value: '$albumsCount'),
        ],
      ),
    );
  }

  void _openUserList(String title, List<String> userIds) async {
    final authUser = context.read<AuthProvider>().currentUser;
    if (authUser == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowersScreen(
          title: title,
          currentUser: authUser,
          userIds: userIds,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshProfileUser();
  }

  User _copyUser(
    User user, {
    List<String>? followerIDs,
    List<String>? followingIDs,
  }) {
    return User(
      uuid: user.uuid,
      username: user.username,
      email: user.email,
      phone: user.phone,
      fullname: user.fullname,
      banned: user.banned,
      followerIDs: followerIDs ?? user.followerIDs,
      followingIDs: followingIDs ?? user.followingIDs,
      userType: user.userType,
    );
  }

  Widget _buildEditProfileButton(BuildContext context, double leftPadding) {
    final authUser = context.read<AuthProvider>().currentUser;
    final authProvider = context.read<AuthProvider>();
    final user = authUser == null
        ? null
        : _editedUser?.uuid == authUser.uuid
        ? _editedUser!
        : authUser;

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, 0, 24, 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        onPressed: user == null
            ? null
            : () async {
                final result = await Navigator.push<_EditProfileResult>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _EditProfileScreen(
                      user: user,
                      onDeleteAccount: () => _deleteAccount(authProvider),
                    ),
                  ),
                );

                if (result == null || !context.mounted) return;

                if (result.profileImageChanged) {
                  UserService.clearProfileImageCache(user.uuid);
                }

                await context.read<AuthProvider>().updateCurrentUser(
                  result.user!,
                );

                if (!context.mounted) return;

                setState(() {
                  _editedUser = result.user;

                  if (result.profileImageChanged) {
                    _profileImageRefreshKey++;
                  }
                });

                context.read<SnackbarFabProvider>().showSnackBar(
                  context,
                  SnackBar(
                    content: Text('Profile saved'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
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

  Future<void> _deleteAccount(AuthProvider authProvider) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'Your photos, albums, and account data will be deleted.',
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
      ),
    );
    if (shouldDelete != true || !mounted) return;

    try {
      await UserService.deleteUser(authProvider.currentUser!.uuid);
      await authProvider.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (error) {
      if (!mounted) return;
      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text('Could not delete account: $error'),
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
      //padding: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
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
  final Future<void> Function() onDeleteAccount;

  const _EditProfileScreen({required this.user, required this.onDeleteAccount});

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullnameController;
  late final TextEditingController _usernameController;
  bool _profileImageChanged = false;
  int _profileImageVersion = 0;

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
      Navigator.pop(
        context,
        _EditProfileResult(
          user: updatedUser,
          profileImageChanged: _profileImageChanged,
        ),
      );
    } catch (error) {
      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text(error.toString()),
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

  String get _contact {
    return widget.user.email ?? widget.user.phone ?? 'No contact info';
  }

  bool get _hasChanges {
    return _fullnameController.text.trim() != widget.user.fullname ||
        _usernameController.text.trim() != (widget.user.username ?? '');
  }

  void _refreshSaveButton() {
    setState(() {});
  }

  void _submitFromKeyboard(String _) {
    _handleSave();
  }

  String? _validateFullname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  Widget _buildAvatar(String firstLetter) {
    return Center(
      child: Stack(
        children: [
          ProfileAvatar(
            userId: widget.user.uuid,
            fullname: firstLetter,
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.primary,
            imageVersion: _profileImageVersion,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  onPressed: () => _pickProfileImage(widget.user.uuid),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage(String userId) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    try {
      await UserService.updateProfileImage(userId, File(image.path));
      UserService.clearProfileImageCache(userId);
      await context.read<AuthProvider>().updateCurrentUser(
        widget.user.copyWith(),
      );

      setState(() {
        _profileImageChanged = true;
        _profileImageVersion++;
      });
    } catch (error) {
      if (!mounted) return;
      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text('Could not upload profile photo: $error'),
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

  @override
  Widget build(BuildContext context) {
    final fullname = _fullnameController.text.trim();
    final firstLetter = fullname.isNotEmpty ? fullname[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatar(firstLetter),
              const SizedBox(height: 28),
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
              ElevatedButton(
                onPressed: _hasChanges ? _handleSave : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _ChangePasswordScreen(user: widget.user),
                    ),
                  );
                  if (changed == true && context.mounted) {
                    context.read<SnackbarFabProvider>().showSnackBar(
                      context,
                      SnackBar(
                        content: Text('Password changed'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.lock_outline),
                label: const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: widget.onDeleteAccount,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordScreen extends StatefulWidget {
  final User user;

  const _ChangePasswordScreen({required this.user});

  @override
  State<_ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await UserService.changePassword(
        userId: widget.user.uuid,
        password: _passwordController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  _isSaving ? 'Saving...' : 'Save Password',
                  style: TextStyle(color: Colors.white),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: Colors.grey,
          child: ServerPhotoImage(
            photoId: photo.uuid,
            aspectRatio: photo.aspectRatio,
            fit: BoxFit.cover,
          ),
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
    final authProvider = context.watch<AuthProvider>();
    final photoProvider = context.watch<PhotoProvider>();
    final authUser = authProvider.currentUser;

    final albumPhotos = photoProvider.photos
        .where(
          (photo) =>
              album.photoIDs.contains(photo.uuid) &&
              (photo.isPublic || photo.ownerID == authUser!.uuid),
        )
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
                      '${albumPhotos.length} ${albumPhotos.length == 1 ? 'photo' : 'photos'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
        aspectRatio: photo.aspectRatio,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatItem({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _EditProfileResult {
  final User? user;
  final bool profileImageChanged;

  const _EditProfileResult({this.user, this.profileImageChanged = false});
}
