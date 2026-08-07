import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/user_service.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({
    super.key,
    required this.userId,
    this.username,
    this.radius = 20,
    this.backgroundColor,
    this.textStyle,
  });

  final String userId;
  final String? username;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = UserService.getProfileImage(widget.userId);
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _imageFuture = UserService.getProfileImage(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final firstLetter = (widget.username?.isNotEmpty ?? false)
        ? widget.username![0].toUpperCase()
        : '?';

    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: widget.backgroundColor ?? colorScheme.primary,
          backgroundImage: snapshot.data != null
              ? MemoryImage(snapshot.data!)
              : null,
          child: snapshot.data != null
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
      },
    );
  }
}
