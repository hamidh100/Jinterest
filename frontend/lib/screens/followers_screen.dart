import 'package:flutter/material.dart';

import '../models/user.dart';
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
  late Set<String> _followingIds;

  List<User> _users = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _userIds = List<String>.from(widget.userIds);
    _followingIds = widget.currentUser.followingIDs.toSet();

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

  void _onFollowChanged(String userId, bool isFollowing) {
    setState(() {
      if (isFollowing) {
        _followingIds.add(userId);
      } else {
        _followingIds.remove(userId);
        if (widget.title.toLowerCase() == 'following') {
          _userIds.remove(userId);
          _users.removeWhere((user) => user.uuid == userId);
        }
      }
    });
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

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = _users[index];

        final isCurrentUser = user.uuid == widget.currentUser.uuid;

        return UserListTile(
          user: user,
          trailing: isCurrentUser
              ? null
              : FollowButton(
                  followerId: widget.currentUser.uuid,
                  followedId: user.uuid,
                  isFollowing: _followingIds.contains(user.uuid),
                  onChanged: (isFollowing) {
                    _onFollowChanged(user.uuid, isFollowing);
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
