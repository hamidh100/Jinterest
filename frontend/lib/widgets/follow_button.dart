import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jinterest/providers/snackbar_fab_provider.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';

enum FollowButtonStyle { compact, profile }

class FollowButton extends StatefulWidget {
  const FollowButton({
    super.key,
    required this.followerId,
    required this.followedId,
    required this.isFollowing,
    this.onChanged,
    this.width = 110,
    this.height = 36,
    this.style = FollowButtonStyle.compact,
  });

  final String followerId;
  final String followedId;
  final bool isFollowing;
  final FutureOr<void> Function(bool isFollowing)? onChanged;

  final double width;
  final double height;
  final FollowButtonStyle style;

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

    final newFollowingState = !widget.isFollowing;

    try {
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

      if (!mounted) return;

      await widget.onChanged?.call(newFollowingState);
    } catch (error) {
      if (!mounted) return;

      context.read<SnackbarFabProvider>().showSnackBar(
        context,
        SnackBar(
          content: const Text('Could not update follow status'),
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
        width: widget.width,
        height: widget.height,
        child: Center(
          child: SizedBox(
            width: widget.style == FollowButtonStyle.profile ? 20 : 18,
            height: widget.style == FollowButtonStyle.profile ? 20 : 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (widget.style == FollowButtonStyle.profile) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: ElevatedButton(
          onPressed: _toggleFollow,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(widget.width, widget.height),
            backgroundColor: widget.isFollowing
                ? Colors.grey.shade300
                : colorScheme.primary,
            foregroundColor: widget.isFollowing ? Colors.black87 : Colors.white,
          ),
          child: Text(widget.isFollowing ? 'Unfollow' : 'Follow'),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.isFollowing
          ? OutlinedButton(
              onPressed: _toggleFollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outline),
              ),
              child: const Text('Following'),
            )
          : FilledButton(
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
