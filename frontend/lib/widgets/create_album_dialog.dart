import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../models/user.dart';
import '../providers/snackbar_fab_provider.dart';

Future<Album?> showCreateAlbumDialog({
  required BuildContext context,
  required User currentUser,
}) {
  return showDialog<Album>(
    context: context,
    builder: (_) {
      return _AlbumDialog(currentUser: currentUser);
    },
  );
}

Future<Album?> showEditAlbumDialog({
  required BuildContext context,
  required Album album,
}) {
  return showDialog<Album>(
    context: context,
    builder: (_) => _AlbumDialog(album: album),
  );
}

class _AlbumDialog extends StatefulWidget {
  final User? currentUser;
  final Album? album;

  const _AlbumDialog({this.currentUser, this.album});

  bool get isEditing => album != null;

  @override
  State<_AlbumDialog> createState() => _AlbumDialogState();
}

class _AlbumDialogState extends State<_AlbumDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.album?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.album?.description ?? '',
    );
    _isPublic = widget.album?.isPublic ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitAlbum() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text('Album name is required'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final existingAlbum = widget.album;
    final album = existingAlbum == null
        ? Album(
            uuid: DateTime.now().microsecondsSinceEpoch.toString(),
            ownerID: widget.currentUser!.uuid,
            name: name,
            description: description.isEmpty ? null : description,
            photoIDs: const [],
            albumAge: DateTime.now(),
            isPublic: _isPublic,
          )
        : Album(
            uuid: existingAlbum.uuid,
            ownerID: existingAlbum.ownerID,
            name: name,
            description: description.isEmpty ? null : description,
            photoIDs: existingAlbum.photoIDs,
            albumAge: existingAlbum.albumAge,
            isPublic: _isPublic,
          );

    Navigator.of(context).pop(album);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Album' : 'Create Album'),
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
        ElevatedButton(
          onPressed: _submitAlbum,
          child: Text(widget.isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
