import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSetting();
  }

  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      final ok = await BiometricService.authenticate();
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed')),
        );
        return;
      }
    }

    await prefs.setBool('biometric_enabled', value);
    setState(() => biometricEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          SwitchListTile(
            title: const Text('Enable biometric unlock'),
            subtitle: const Text('Use fingerprint or face unlock'),
            value: biometricEnabled,
            onChanged: _toggleBiometric,
          ),

          const Divider(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
