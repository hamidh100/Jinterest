import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';

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

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

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
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerID: currentUser.uuid,
        path: _selectedImage!.path,
        name: _photoName.trim(),
        categoryList: tags,
        captionText: _caption.trim().isEmpty ? null : _caption.trim(),
        photoAge: DateTime.now(),
      );

      final success = await context.read<PhotoProvider>().addPhoto(photo);

      if (!mounted) return;

      if (success) {
        _showToast('Photo uploaded successfully');
        Navigator.pop(context);
      } else {
        final error = context.read<PhotoProvider>().errorMessage;
        _showToast(error ?? 'Upload failed', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Upload failed: $e', isError: true);
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
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Photo'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 16),
              _buildPickButtons(),
              const SizedBox(height: 24),
              _buildPhotoNameField(),
              const SizedBox(height: 16),
              _buildCaptionField(),
              const SizedBox(height: 16),
              _buildTagsField(),
              const SizedBox(height: 24),
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _pickFromGallery,
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade400),
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
      onSaved: (value) {
        _photoName = value ?? '';
      },
    );
  }

  Widget _buildCaptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Caption',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onSaved: (value) {
        _caption = value ?? '';
      },
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Tags / categories',
        hintText: 'nature, travel, family',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) {
        _tagsText = value ?? '';
      },
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadPhoto,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.deepPurple,
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isUploading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Upload',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
