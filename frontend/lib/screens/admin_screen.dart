import 'package:flutter/material.dart';

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
              // Open users screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Photos'),
            subtitle: const Text('Manage photos'),
            onTap: () {
              // Open photos screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('Albums'),
            subtitle: const Text('Manage albums'),
            onTap: () {
              // Open albums screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.comment),
            title: const Text('Comments'),
            subtitle: const Text('Manage comments'),
            onTap: () {
              // Open comments screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Audit Log'),
            subtitle: const Text('View administrative actions'),
            onTap: () {
              // Open audit log
            },
          ),
        ],
      ),
    );
  }
}
