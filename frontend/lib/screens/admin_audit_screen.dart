import 'package:flutter/material.dart';
import '../services/api_client.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  List<String> logs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAudit();
  }

  Future<void> loadAudit() async {
    final res = await ApiClient.instance.send(
      method: 'GET',
      route: '/admin/audit',
    );

    setState(() {
      logs = List<String>.from(res['payload']['audit']);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Audit Log')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: ListView(
        children: logs.map((log) {
          return ListTile(title: Text(log));
        }).toList(),
      ),
    );
  }
}
