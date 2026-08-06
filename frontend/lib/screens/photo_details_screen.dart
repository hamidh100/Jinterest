import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/photo.dart';
import '../providers/album_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/photo_provider.dart';
import '../widgets/info_chip.dart';
import '../widgets/uploader_tile.dart';
import '../widgets/server_photo_image.dart';
import '../widgets/create_album_dialog.dart';
import '../services/photo_service.dart';

class PhotoDetailsScreen extends StatefulWidget {
  final String photoId;

  const PhotoDetailsScreen({super.key, required this.photoId});

  @override
  State<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends State<PhotoDetailsScreen> {
  List<Comment> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingComments = true;
  bool _isAddingComment = false;
  String? _commentError;

  static const _deletePhotoAction = 'delete';
  static const _changeAlbumsAction = 'change_albums';
  static const _toggleCommentsAction = 'toggle_comments';

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit photo',
              onSelected: (action) {
                if (action == _deletePhotoAction) {
                  _confirmDelete(context, photo);
                } else if (action == _changeAlbumsAction) {
                  _changePhotoAlbums(photo);
                } else {
                  _toggleCommentsAllowed(photo);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _changeAlbumsAction,
                  child: const Text('Change albums'),
                ),
                PopupMenuItem(
                  value: _toggleCommentsAction,
                  child: Text(
                    photo.commentsAllowed
                        ? 'Disable comments'
                        : 'Enable comments',
                  ),
                ),
                const PopupMenuItem(
                  value: _deletePhotoAction,
                  child: Text(
                    'Delete photo',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
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
              _buildCommentsSection(context, photo),
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

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

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
      setState(() {
        _comments.add(comment);
        _commentController.clear();
      });
      await photoProvider.loadPhotos();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not add comment: $error')));
    } finally {
      if (mounted) setState(() => _isAddingComment = false);
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final photoProvider = context.read<PhotoProvider>();
    try {
      await PhotoService.deleteComment(comment.uuid);
      if (!mounted) return;
      setState(
        () => _comments.removeWhere((item) => item.uuid == comment.uuid),
      );
      await photoProvider.loadPhotos();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete comment: $error')),
      );
    }
  }

  Widget _buildImage(Photo photo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ServerPhotoImage(
          photoId: photo.uuid,
          aspectRatio: photo.aspectRatio,
          fit: BoxFit.cover,
        ),
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
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
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

  Widget _buildCommentsSection(BuildContext context, Photo photo) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final canComment =
        currentUser != null &&
        (photo.commentsAllowed || currentUser.uuid == photo.ownerID);

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

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  enabled: canComment && !_isAddingComment,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _addComment(),
                  decoration: InputDecoration(
                    hintText: canComment
                        ? 'Write a comment'
                        : 'Comments are disabled',
                  ),
                ),
              ),
              IconButton(
                onPressed: !canComment || _isAddingComment ? null : _addComment,
                icon: _isAddingComment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                tooltip: 'Post comment',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCommentsAllowed(Photo photo) async {
    final commentsAllowed = !photo.commentsAllowed;
    final success = await context.read<PhotoProvider>().updateCommentsAllowed(
      photoId: photo.uuid,
      commentsAllowed: commentsAllowed,
    );
    if (!mounted) return;
    final error = context.read<PhotoProvider>().errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Comments ${commentsAllowed ? 'enabled' : 'disabled'}'
              : error ?? 'Could not update comment permission',
        ),
        backgroundColor: success ? null : Colors.red,
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

  Future<void> _changePhotoAlbums(Photo photo) async {
    final albumProvider = context.read<AlbumProvider>();
    await albumProvider.loadAlbums();

    if (!mounted) return;

    final albums = albumProvider.getUserAlbums(photo.ownerID);
    final currentAlbumIds = albums
        .where((album) => album.photoIDs.contains(photo.uuid))
        .map((album) => album.uuid)
        .toSet();
    final selectedAlbumIds = Set<String>.from(currentAlbumIds);

    final result = await showDialog<_AlbumSelection>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change albums'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ...albums.map(
                  (album) => CheckboxListTile(
                    value: selectedAlbumIds.contains(album.uuid),
                    title: Text(album.name),
                    onChanged: (isSelected) {
                      setDialogState(() {
                        if (isSelected == true) {
                          selectedAlbumIds.add(album.uuid);
                        } else {
                          selectedAlbumIds.remove(album.uuid);
                        }
                      });
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add to new album'),
                  onTap: () => Navigator.pop(
                    dialogContext,
                    const _AlbumSelection.createNew(),
                  ),
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
              onPressed: () => Navigator.pop(
                dialogContext,
                _AlbumSelection.selected(Set<String>.from(selectedAlbumIds)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;
    if (result.createNewAlbum) {
      await _createAlbumForPhoto(photo);
      return;
    }

    final updatedAlbumIds = result.selectedAlbumIds;
    if (updatedAlbumIds == null) return;

    var isSuccess = true;
    for (final albumId in updatedAlbumIds.difference(currentAlbumIds)) {
      final wasAdded = await albumProvider.addPhotoToAlbum(
        albumId: albumId,
        photoId: photo.uuid,
      );
      if (!wasAdded) isSuccess = false;
    }
    for (final albumId in currentAlbumIds.difference(updatedAlbumIds)) {
      final wasRemoved = await albumProvider.removePhotoFromAlbum(
        albumId: albumId,
        photoId: photo.uuid,
      );
      if (!wasRemoved) isSuccess = false;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess
              ? 'Albums updated'
              : albumProvider.errorMessage ?? 'Could not update albums',
        ),
        backgroundColor: isSuccess ? null : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createAlbumForPhoto(Photo photo) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    final album = await showCreateAlbumDialog(
      context: context,
      currentUser: currentUser,
    );
    if (album == null || !mounted) return;

    final albumProvider = context.read<AlbumProvider>();
    final createdAlbum = await albumProvider.createAlbum(album);
    var wasAdded = false;
    if (createdAlbum != null) {
      wasAdded = await albumProvider.addPhotoToAlbum(
        albumId: createdAlbum.uuid,
        photoId: photo.uuid,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasAdded
              ? 'Album created and photo added'
              : albumProvider.errorMessage ?? 'Could not create album',
        ),
        backgroundColor: wasAdded ? null : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AlbumSelection {
  final Set<String>? selectedAlbumIds;
  final bool createNewAlbum;

  const _AlbumSelection.selected(this.selectedAlbumIds)
    : createNewAlbum = false;

  const _AlbumSelection.createNew()
    : selectedAlbumIds = null,
      createNewAlbum = true;
}
