import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/profile_avatar.dart';

class FollowersScreen extends StatefulWidget {
  final String title;
  final List<String> userIds;

  const FollowersScreen({
    super.key,
    required this.title,
    required this.userIds,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await Future.wait(
        widget.userIds.map(UserService.getUserById),
      );
      if (!mounted) return;
      setState(() => _users = users.whereType<User>().toList());
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load users');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _users.isEmpty
          ? Center(child: Text('No ${widget.title.toLowerCase()} yet'))
          : ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: ProfileAvatar(
                    userId: user.uuid,
                    fullname: user.fullname,
                    radius: 22,
                  ),
                  title: Text(
                    user.fullname.isEmpty ? 'Unknown User' : user.fullname,
                  ),
                  subtitle: Text('@${user.username ?? 'unknown'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/user-profile',
                    arguments: user.uuid,
                  ),
                );
              },
            ),
    );
  }
}
