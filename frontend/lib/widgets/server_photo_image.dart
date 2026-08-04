import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/photo_service.dart';

class ServerPhotoImage extends StatefulWidget {
  const ServerPhotoImage({
    super.key,
    required this.photoId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String photoId;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  State<ServerPhotoImage> createState() => _ServerPhotoImageState();
}

class _ServerPhotoImageState extends State<ServerPhotoImage> {
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = PhotoService.getPhotoImage(widget.photoId);
  }

  @override
  void didUpdateWidget(covariant ServerPhotoImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.photoId != widget.photoId) {
      _imageFuture = PhotoService.getPhotoImage(widget.photoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: Icon(Icons.broken_image_outlined, size: 36),
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          gaplessPlayback: true,
        );
      },
    );
  }
}
