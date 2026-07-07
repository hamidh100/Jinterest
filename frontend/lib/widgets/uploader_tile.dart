import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

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
    final User? uploader = UserService.getUserById(ownerID);

    final displayName = uploader?.fullname.trim().isNotEmpty == true
        ? uploader!.fullname.trim()
        : uploader?.username ?? 'Unknown user';

    final username = uploader?.username;

    final firstLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: uploader == null
            ? null
            : onTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User profile screen coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primary,
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
