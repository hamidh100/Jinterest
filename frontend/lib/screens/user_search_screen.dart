import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/user_list_tile.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<User> _users = [];
  bool _isSearching = false;
  String _query = '';

  Timer? _debounce;
  int _searchRequest = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();

    setState(() {
      _query = query;
    });

    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _users = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _searchUsers(query),
    );
  }

  Future<void> _searchUsers(String query) async {
    final request = ++_searchRequest;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = null; //await UserService.searchUsers(query);

      if (!mounted || request != _searchRequest) return;

      setState(() {
        _users = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted || request != _searchRequest) return;

      setState(() {
        _users = [];
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _query = '';
      _users = [];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),

          if (_isSearching) const LinearProgressIndicator(),

          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isEmpty) {
      return const Center(child: Text('Search for a user'));
    }

    if (!_isSearching && _users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];

        return UserListTile(
          user: user,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/user-profile', arguments: user.uuid);
          },
        );
      },
    );
  }
}
