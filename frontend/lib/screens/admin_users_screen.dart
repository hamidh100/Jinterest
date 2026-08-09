import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/user_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final res = await ApiClient.instance.send(
      method: 'GET',
      route: '/admin/users',
    );

    final list = res['payload']['users'] as List;
    setState(() {
      users = UserService.parseUserList(list);
      loading = false;
    });
  }

  Future<void> banUser(String id) async {
    await ApiClient.instance.send(method: 'PUT', route: '/admin/users/$id/ban');
    loadUsers();
  }

  Future<void> unbanUser(String id) async {
    await ApiClient.instance.send(
      method: 'PUT',
      route: '/admin/users/$id/unban',
    );
    loadUsers();
  }

  Future<void> deleteUser(String id) async {
    await ApiClient.instance.send(method: 'DELETE', route: '/admin/users/$id');
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: ListView(
        children: users.map((u) {
          return ListTile(
            title: Text(u.fullname),
            subtitle: Text('@${u.username}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!u.banned)
                  IconButton(
                    icon: const Icon(Icons.block, color: Colors.red),
                    onPressed: () => banUser(u.uuid),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => unbanUser(u.uuid),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteUser(u.uuid),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
