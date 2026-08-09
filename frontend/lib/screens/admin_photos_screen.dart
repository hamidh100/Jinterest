import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AdminPhotosScreen extends StatefulWidget {
  const AdminPhotosScreen({super.key});

  @override
  State<AdminPhotosScreen> createState() => _AdminPhotosScreenState();
}

class _AdminPhotosScreenState extends State<AdminPhotosScreen> {
  List<dynamic> photos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    final res = await ApiClient.instance.send(
      method: 'GET',
      route: '/admin/photos',
    );

    setState(() {
      photos = res['payload']['photos'];
      loading = false;
    });
  }

  Future<void> deletePhoto(String id) async {
    await ApiClient.instance.send(method: 'DELETE', route: '/admin/photos/$id');
    loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Photos')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Photos')),
      body: ListView(
        children: photos.map((p) {
          return ListTile(
            title: Text(p['name'] ?? 'Unnamed'),
            subtitle: Text('Owner: ${p['ownerId']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deletePhoto(p['id']),
            ),
          );
        }).toList(),
      ),
    );
  }
}
