import 'package:flutter/material.dart';

import '../models/album.dart';
import '../models/user.dart';

Future<Album?> showCreateAlbumDialog({
  required BuildContext context,
  required User currentUser,
}) {
  return showDialog<Album>(
    context: context,
    builder: (_) {
      return _CreateAlbumDialog(currentUser: currentUser);
    },
  );
}

class _CreateAlbumDialog extends StatefulWidget {
  final User currentUser;

  const _CreateAlbumDialog({required this.currentUser});

  @override
  State<_CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<_CreateAlbumDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createAlbum() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Album name is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final album = Album(
      uuid: DateTime.now().microsecondsSinceEpoch.toString(),
      ownerID: widget.currentUser.uuid,
      name: name,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      photoIDs: const [],
      albumAge: DateTime.now(),
      isPublic: _isPublic,
    );

    Navigator.of(context).pop(album);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Album'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Album name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isPublic,
              title: const Text('Public album'),
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _createAlbum, child: const Text('Create')),
      ],
    );
  }
}
