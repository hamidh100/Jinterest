import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AdminCommentsScreen extends StatefulWidget {
  const AdminCommentsScreen({super.key});

  @override
  State<AdminCommentsScreen> createState() => _AdminCommentsScreenState();
}

class _AdminCommentsScreenState extends State<AdminCommentsScreen> {
  List<dynamic> comments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    final res = await ApiClient.instance.send(
      method: 'GET',
      route: '/admin/comments',
    );

    setState(() {
      comments = res['payload']['comments'];
      loading = false;
    });
  }

  Future<void> deleteComment(String id) async {
    await ApiClient.instance.send(
      method: 'DELETE',
      route: '/admin/comments/$id',
    );
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Comments')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: ListView(
        children: comments.map((c) {
          return ListTile(
            title: Text(c['text']),
            subtitle: Text('User: ${c['userId']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteComment(c['id']),
            ),
          );
        }).toList(),
      ),
    );
  }
}
