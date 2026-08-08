import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({
    super.key,
    required this.userId,
    this.fullname,
    this.radius = 20,
    this.backgroundColor,
    this.textStyle,
  });

  final String userId;
  final String? fullname;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  late Future<Uint8List?> _imageFuture;
  Future<User?>? _userFuture;

  @override
  void initState() {
    super.initState();

    _imageFuture = UserService.getProfileImage(widget.userId);

    if (widget.fullname == null) {
      _userFuture = UserService.getUserById(widget.userId);
    }
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _imageFuture = UserService.getProfileImage(widget.userId);

      if (widget.fullname == null) {
        _userFuture = UserService.getUserById(widget.userId);
      } else {
        _userFuture = null;
      }
    } else if (oldWidget.fullname != widget.fullname) {
      if (widget.fullname == null) {
        _userFuture = UserService.getUserById(widget.userId);
      } else {
        _userFuture = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, imageSnapshot) {
        if (widget.fullname != null) {
          return _buildAvatar(context, imageSnapshot.data, widget.fullname);
        }
        return FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, userSnapshot) {
            final fullname = userSnapshot.data?.fullname;
            return _buildAvatar(context, imageSnapshot.data, fullname);
          },
        );
      },
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    Uint8List? imageBytes,
    String? fullname,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final firstLetter = fullname?.trim().isNotEmpty == true
        ? fullname!.trim()[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? colorScheme.primary,
      backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
      child: imageBytes != null
          ? null
          : Text(
              firstLetter,
              style:
                  widget.textStyle ??
                  TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.radius * 0.8,
                  ),
            ),
    );
  }
}
