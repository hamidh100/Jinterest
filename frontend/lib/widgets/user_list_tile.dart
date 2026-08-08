import 'package:flutter/material.dart';

import '../models/user.dart';
import 'profile_avatar.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    super.key,
    required this.user,
    this.trailing,
    this.onTap,
  });

  final User user;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = user.fullname.trim().isNotEmpty
        ? user.fullname.trim()
        : user.username ?? 'Unknown User';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: ProfileAvatar(
        userId: user.uuid,
        fullname: displayName,
        radius: 22,
      ),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '@${user.username ?? 'unknown'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
