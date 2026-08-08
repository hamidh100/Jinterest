import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'profile_avatar.dart';

class UploaderTile extends StatelessWidget {
  final String ownerID;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const UploaderTile({
    super.key,
    required this.ownerID,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: UserService.getUserById(ownerID),
      builder: (context, snapshot) => _buildTile(context, snapshot.data),
    );
  }

  Widget _buildTile(BuildContext context, User? uploader) {
    final displayName = uploader?.fullname.trim().isNotEmpty == true
        ? uploader!.fullname.trim()
        : uploader?.username ?? 'Unknown user';

    final username = uploader?.username;

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: uploader == null
            ? null
            : onTap ??
                  () => Navigator.pushNamed(
                    context,
                    '/user-profile',
                    arguments: ownerID,
                  ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ProfileAvatar(
                userId: ownerID,
                fullname: uploader?.fullname,
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (username != null && username.trim().isNotEmpty)
                      Text(
                        '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
