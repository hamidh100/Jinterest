import 'package:flutter/material.dart';
import 'package:jinterest/widgets/user_list_tile.dart';

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
    return FutureBuilder<User?>(
      future: UserService.getUserById(ownerID),
      builder: (context, snapshot) => _buildTile(context, snapshot.data),
    );
  }

  Widget _buildTile(BuildContext context, User? uploader) {
    final colorScheme = Theme.of(context).colorScheme;

    return UserListTile(
      user: uploader!,
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      onTap: () =>
          Navigator.pushNamed(context, '/user-profile', arguments: ownerID),
    );
  }
}
