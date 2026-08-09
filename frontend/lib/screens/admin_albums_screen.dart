import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AdminAlbumsScreen extends StatefulWidget {
  const AdminAlbumsScreen({super.key});

  @override
  State<AdminAlbumsScreen> createState() => _AdminAlbumsScreenState();
}

class _AdminAlbumsScreenState extends State<AdminAlbumsScreen> {
  List<dynamic> albums = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    final res = await ApiClient.instance.send(
      method: 'GET',
      route: '/admin/albums',
    );

    setState(() {
      albums = res['payload']['albums'];
      loading = false;
    });
  }

  Future<void> deleteAlbum(String id) async {
    await ApiClient.instance.send(method: 'DELETE', route: '/admin/albums/$id');
    loadAlbums();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Albums')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      body: ListView(
        children: albums.map((a) {
          return ListTile(
            title: Text(a['name']),
            subtitle: Text('Owner: ${a['ownerId']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteAlbum(a['id']),
            ),
          );
        }).toList(),
      ),
    );
  }
}
