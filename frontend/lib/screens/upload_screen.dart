import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../widgets/create_album_dialog.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String _photoName = '';
  String _caption = '';
  String _tagsText = '';
  bool _isUploading = false;
  bool _isPublic = false;

  final Set<String> _selectedAlbumIds = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<AlbumProvider>().loadAlbums();
    });
  }

  Future<void> _pickFromGallery() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  Future<void> _pickFromCamera() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  Future<void> _uploadPhoto() async {
    if (_isUploading) return;

    if (_selectedImage == null) {
      _showToast('Please select an image first', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      _showToast('You must be logged in to upload photos', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final tags = _tagsText
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final photo = Photo(
        uuid: DateTime.now().microsecondsSinceEpoch.toString(),
        ownerID: currentUser.uuid,
        path: _selectedImage!.path,
        name: _photoName.trim(),
        captionText: _caption.trim().isEmpty ? null : _caption.trim(),
        categoryList: tags,
        photoAge: DateTime.now(),
        isPublic: _isPublic,
      );

      final photoSuccess = await context.read<PhotoProvider>().addPhoto(photo);

      if (!photoSuccess) {
        final error = context.read<PhotoProvider>().errorMessage;
        _showToast(error ?? 'Failed to upload photo', isError: true);
        return;
      }

      final albumProvider = context.read<AlbumProvider>();

      for (final albumId in _selectedAlbumIds) {
        await albumProvider.addPhotoToAlbum(
          albumId: albumId,
          photoId: photo.uuid,
        );
      }

      if (!mounted) return;

      _showToast('Photo uploaded successfully');

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        _showToast('Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleCreateAlbum() async {
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      _showToast('You must be logged in to create an album', isError: true);
      return;
    }

    final album = await showCreateAlbumDialog(
      context: context,
      currentUser: currentUser,
    );

    if (!mounted || album == null) return;

    final success = await context.read<AlbumProvider>().createAlbum(album);

    if (!mounted) return;

    if (!success) {
      final error = context.read<AlbumProvider>().errorMessage;
      _showToast(error ?? 'Failed to create album', isError: true);
      return;
    }

    setState(() {
      _selectedAlbumIds.add(album.uuid);
    });

    _showToast('Album created');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Photo'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 16),
                _buildPickButtons(),
                const SizedBox(height: 24),
                _buildPhotoNameField(),
                const SizedBox(height: 16),
                _buildCaptionField(),
                const SizedBox(height: 16),
                _buildTagsField(),
                const SizedBox(height: 24),
                _buildAlbumSelector(),
                const SizedBox(height: 24),
                _buildPublicToggle(),
                const SizedBox(height: 32),
                _buildUploadButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _isUploading ? null : _pickFromGallery,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.shade100),
        ),
        child: _selectedImage == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 72,
                    color: Colors.deepPurple,
                  ),
                  SizedBox(height: 12),
                  Text('Tap to choose an image'),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildPickButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isUploading ? null : _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isUploading ? null : _pickFromCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Photo name',
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Photo name is required';
        }
        return null;
      },
      onSaved: (value) => _photoName = value ?? '',
    );
  }

  Widget _buildCaptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Caption',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onSaved: (value) => _caption = value ?? '',
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Tags',
        hintText: 'nature, travel, friends',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => _tagsText = value ?? '',
    );
  }

  Widget _buildAlbumSelector() {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final albumProvider = context.watch<AlbumProvider>();

    if (currentUser == null) return const SizedBox.shrink();

    final userAlbums = albumProvider.albums
        .where((album) => album.ownerID == currentUser.uuid)
        .toList();

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Add to albums',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: _isUploading ? null : _handleCreateAlbum,
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (albumProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (userAlbums.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No albums yet. Create one first.'),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: userAlbums.map((album) {
                final selected = _selectedAlbumIds.contains(album.uuid);

                return FilterChip(
                  label: Text(album.name),
                  selected: selected,
                  onSelected: _isUploading
                      ? null
                      : (value) {
                          setState(() {
                            if (value) {
                              _selectedAlbumIds.add(album.uuid);
                            } else {
                              _selectedAlbumIds.remove(album.uuid);
                            }
                          });
                        },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _uploadPhoto,
        icon: _isUploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload),
        label: Text(_isUploading ? 'Uploading...' : 'Upload Photo'),
      ),
    );
  }

  Widget _buildPublicToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Public photo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Public photos can be shown in Explore.'),
        value: _isPublic,
        onChanged: _isUploading
            ? null
            : (value) {
                setState(() {
                  _isPublic = value;
                });
              },
      ),
    );
  }
}
