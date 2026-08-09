import 'package:flutter/material.dart';
import 'admin_users_screen.dart';
import 'admin_photos_screen.dart';
import 'admin_albums_screen.dart';
import 'admin_comments_screen.dart';
import 'admin_audit_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            subtitle: const Text('Manage users and accounts'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Photos'),
            subtitle: const Text('Manage photos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPhotosScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('Albums'),
            subtitle: const Text('Manage albums'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAlbumsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.comment),
            title: const Text('Comments'),
            subtitle: const Text('Manage comments'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCommentsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Audit Log'),
            subtitle: const Text('View administrative actions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAuditScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
