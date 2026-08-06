import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/photo_service.dart';

class ServerPhotoImage extends StatefulWidget {
  const ServerPhotoImage({
    super.key,
    required this.photoId,
    this.aspectRatio = 1.0,
    this.fit = BoxFit.cover,
  });

  final String photoId;
  final double aspectRatio;
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
    return AspectRatio(
      aspectRatio: widget.aspectRatio > 0 ? widget.aspectRatio : 1.0,
      child: FutureBuilder<Uint8List>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ColoredBox(
              color: Color(0xFFAAAAAA),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const ColoredBox(
              color: Color(0xFFAAAAAA),
              child: Center(child: Icon(Icons.broken_image_outlined)),
            );
          }

          return Image.memory(
            snapshot.data!,
            fit: widget.fit,
            gaplessPlayback: true,
          );
        },
      ),
    );
  }
}
