import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/photo.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../widgets/info_chip.dart';
import '../widgets/uploader_tile.dart';
import '../widgets/server_photo_image.dart';
import '../services/photo_service.dart';

class PhotoDetailsScreen extends StatefulWidget {
  final String photoId;

  const PhotoDetailsScreen({super.key, required this.photoId});

  @override
  State<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends State<PhotoDetailsScreen> {
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  bool _isAddingComment = false;
  String? _commentError;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    final photo = _findPhoto(photoProvider.photos, widget.photoId);

    if (photo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Photo Details')),
        body: const Center(child: Text('Photo not found')),
      );
    }

    final isOwner = currentUser != null && currentUser.uuid == photo.ownerID;
    final isLiked =
        currentUser != null && photo.likeIDs.contains(currentUser.uuid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo'),
        centerTitle: true,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, photo),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(photo),
              const SizedBox(height: 16),
              _buildHeader(context, photo, isLiked),
              const SizedBox(height: 4),
              UploaderTile(ownerID: photo.ownerID),
              const SizedBox(height: 16),
              _buildCaption(context, photo),
              _buildTags(photo),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: const Divider(height: 32),
              ),
              _buildInfo(photo),
              Container(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: const Divider(height: 32),
              ),
              _buildCommentsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Photo? _findPhoto(List<Photo> photos, String id) {
    try {
      return photos.firstWhere((photo) => photo.uuid == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await PhotoService.getComments(widget.photoId);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
        _commentError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingComments = false;
        _commentError = 'Could not load comments: $error';
      });
    }
  }

  Future<void> _openAddCommentDialog() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add comment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Write a comment'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Post'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted || text == null || text.trim().isEmpty) return;
    await _addComment(text);
  }

  Future<void> _addComment(String text) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    final photoProvider = context.read<PhotoProvider>();
    if (currentUser == null) return;

    setState(() => _isAddingComment = true);
    try {
      final comment = await PhotoService.addComment(
        photoId: widget.photoId,
        userId: currentUser.uuid,
        text: text,
      );
      if (!mounted) return;
      setState(() => _comments.add(comment));
      await photoProvider.loadPhotos();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add comment: $error')),
      );
    } finally {
      if (mounted) setState(() => _isAddingComment = false);
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final photoProvider = context.read<PhotoProvider>();
    try {
      await PhotoService.deleteComment(comment.uuid);
      if (!mounted) return;
      setState(() => _comments.removeWhere((item) => item.uuid == comment.uuid));
      await photoProvider.loadPhotos();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete comment: $error')),
      );
    }
  }

  Widget _buildImage(Photo photo) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: ServerPhotoImage(
        photoId: photo.uuid,
        width: double.infinity,
        height: 350,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Photo photo, bool isLiked) {
    final currentUser = context.read<AuthProvider>().currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              photo.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : null,
            ),
            onPressed: currentUser == null
                ? null
                : () {
                    context.read<PhotoProvider>().toggleLike(
                      photoId: photo.uuid,
                      userId: currentUser.uuid,
                    );
                  },
          ),
          Text('${photo.likeIDs.length}'),
        ],
      ),
    );
  }

  Widget _buildCaption(BuildContext context, Photo photo) {
    if (photo.captionText == null || photo.captionText!.trim().isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No caption',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.45),
            height: 1.35,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        photo.captionText!,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _buildTags(Photo photo) {
    if (photo.categoryList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: photo.categoryList.map((tag) {
          return Chip(
            label: Text(tag),
            backgroundColor: Colors.deepPurple.shade100,
            labelStyle: const TextStyle(color: Colors.deepPurple),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfo(Photo photo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          InfoChip(
            icon: photo.isPublic ? Icons.public : Icons.lock_outline,
            label: photo.isPublic ? 'Public' : 'Private',
          ),
          InfoChip(
            icon: Icons.favorite,
            label:
                '${photo.likeIDs.length} ${photo.likeIDs.length == 1 ? 'like' : 'likes'}',
            iconColor: Colors.red,
          ),
          InfoChip(
            icon: Icons.comment_outlined,
            label:
                '${photo.commentIDs.length} ${photo.commentIDs.length == 1 ? 'comment' : 'comments'}',
          ),
          InfoChip(
            icon: Icons.calendar_today_outlined,
            label:
                '${photo.photoAge.year}/${photo.photoAge.month.toString().padLeft(2, '0')}/${photo.photoAge.day.toString().padLeft(2, '0')} ${photo.photoAge.hour.toString().padLeft(2, '0')}:${photo.photoAge.minute.toString().padLeft(2, '0')}',
          ),
          if (photo.categoryList.isNotEmpty)
            InfoChip(
              icon: Icons.sell_outlined,
              label:
                  '${photo.categoryList.length} ${photo.categoryList.length == 1 ? 'tag' : 'tags'}',
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_isLoadingComments)
            const Center(child: CircularProgressIndicator())
          else if (_commentError != null)
            Text(_commentError!, style: const TextStyle(color: Colors.red))
          else if (_comments.isEmpty)
            const Text('No comments yet', style: TextStyle(color: Colors.grey))
          else
            ..._comments.map(
              (comment) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(comment.username ?? 'User'),
                subtitle: Text(comment.text),
                trailing: currentUser?.uuid == comment.userID
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteComment(comment),
                      )
                    : null,
              ),
            ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: currentUser == null || _isAddingComment
                ? null
                : _openAddCommentDialog,
            icon: const Icon(Icons.comment_outlined),
            label: Text(_isAddingComment ? 'Posting...' : 'Add Comment'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Photo photo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete photo?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final success = await context.read<PhotoProvider>().deletePhoto(photo.uuid);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } else {
      final error = context.read<PhotoProvider>().errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Delete failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
