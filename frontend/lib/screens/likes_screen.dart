import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/photo.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PhotoProvider>().loadPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final photoProvider = context.watch<PhotoProvider>();

    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('You are not logged in')));
    }

    final likedPhotos = photoProvider.getLikedPhotos(currentUser.uuid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Photos'),
        centerTitle: true,
        elevation: 0,
      ),
      body: photoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedPhotos.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: likedPhotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return _LikedPhotoTile(photo: likedPhotos[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No liked photos yet',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _LikedPhotoTile extends StatelessWidget {
  final Photo photo;

  const _LikedPhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    final file = File(photo.path);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/photo-details', arguments: photo.uuid);
      },
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.grey[300],
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (file.existsSync())
                Image.file(file, fit: BoxFit.cover)
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(photo.name, textAlign: TextAlign.center),
                    ),
                  ],
                ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          photo.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.favorite, color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${photo.likeIDs.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
