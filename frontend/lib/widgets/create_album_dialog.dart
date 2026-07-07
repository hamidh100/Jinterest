import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';

Future<Album?> showCreateAlbumDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isPublic = false;

  final currentUser = context.read<AuthProvider>().currentUser;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You must be logged in to create an album'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return null;
  }

  final createdAlbum = await showDialog<Album>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create Album'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Album name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isPublic,
                    title: const Text('Public album'),
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();

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
                    ownerID: currentUser.uuid,
                    name: name,
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                    photoIDs: const [],
                    albumAge: DateTime.now(),
                    isPublic: isPublic,
                  );

                  Navigator.pop(dialogContext, album);
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  descriptionController.dispose();

  if (createdAlbum == null) return null;

  final success = await context.read<AlbumProvider>().createAlbum(createdAlbum);

  if (!success) {
    final error = context.read<AlbumProvider>().errorMessage;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to create album'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Album created'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  return createdAlbum;
}
