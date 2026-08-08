import 'package:flutter/material.dart';
import 'package:jinterest/providers/snackbar_fab_provider.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';

class FollowButton extends StatefulWidget {
  const FollowButton({
    super.key,
    required this.followerId,
    required this.followedId,
    required this.isFollowing,
    this.onChanged,
  });

  final String followerId;
  final String followedId;
  final bool isFollowing;
  final ValueChanged<bool>? onChanged;

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isLoading = false;

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newFollowingState = !widget.isFollowing;

      if (widget.isFollowing) {
        await UserService.unfollow(
          followerId: widget.followerId,
          followedId: widget.followedId,
        );
      } else {
        await UserService.follow(
          followerId: widget.followerId,
          followedId: widget.followedId,
        );
      }

      widget.onChanged?.call(newFollowingState);
    } catch (_) {
      if (!mounted) return;

      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: Text('Could not update follow status'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return SizedBox(
        width: 110,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (widget.isFollowing) {
      return SizedBox(
        width: 110,
        height: 36,
        child: OutlinedButton(
          onPressed: _toggleFollow,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline),
          ),
          child: const Text('Following'),
        ),
      );
    }

    return SizedBox(
      width: 110,
      height: 36,
      child: FilledButton(
        onPressed: _toggleFollow,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: const Text('Follow'),
      ),
    );
  }
}
