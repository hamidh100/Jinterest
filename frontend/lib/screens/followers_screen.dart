import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/follow_button.dart';
import '../widgets/user_list_tile.dart';
import '../services/user_service.dart';

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({
    super.key,
    required this.title,
    required this.userIds,
    required this.currentUser,
  });

  final String title;
  final List<String> userIds;
  final User currentUser;

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late List<String> _userIds;

  List<User> _users = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _userIds = List<String>.from(widget.userIds);

    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await Future.wait(_userIds.map(UserService.getUserById));

      if (!mounted) return;

      setState(() {
        _users = users.whereType<User>().toList();
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not load users';
        _isLoading = false;
      });
    }
  }

  Future<void> _onFollowChanged(String userId, bool isFollowing) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;
    final followingIds = List<String>.from(currentUser.followingIDs);
    if (isFollowing) {
      if (!followingIds.contains(userId)) {
        followingIds.add(userId);
      }
    } else {
      followingIds.remove(userId);
    }
    final updatedUser = _copyUser(currentUser, followingIDs: followingIds);
    await authProvider.updateCurrentUser(updatedUser);
    if (!mounted) return;
    setState(() {
      if (!isFollowing && widget.title.toLowerCase() == 'following') {
        _userIds.remove(userId);
        _users.removeWhere((user) => user.uuid == userId);
      }
    });
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

  Future<void> _refresh() async {
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: RefreshIndicator(onRefresh: _refresh, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 300, child: Center(child: Text(_error!)))],
      );
    }

    if (_users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(child: Text('No ${widget.title.toLowerCase()} yet')),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];

        final authUser = context.watch<AuthProvider>().currentUser;

        final isCurrentUser = user.uuid == authUser?.uuid;

        return UserListTile(
          user: user,
          trailing: isCurrentUser
              ? null
              : FollowButton(
                  followerId: authUser!.uuid,
                  followedId: user.uuid,
                  isFollowing: authUser.followingIDs.contains(user.uuid),
                  onChanged: (isFollowing) {
                    return _onFollowChanged(user.uuid, isFollowing);
                  },
                ),
          onTap: () {
            Navigator.pushNamed(context, '/user-profile', arguments: user.uuid);
          },
        );
      },
    );
  }
}
