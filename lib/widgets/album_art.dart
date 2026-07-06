import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AlbumArt extends StatelessWidget {
  final String? artUri;
  final double size;
  final double borderRadius;
  final bool showShadow;

  const AlbumArt({
    super.key,
    this.artUri,
    this.size = 280,
    this.borderRadius = 20,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow ? AppColors.floatingShadow : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (artUri != null && artUri!.isNotEmpty) {
      if (artUri!.startsWith('http')) {
        return Image.network(
          artUri!,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildPlaceholder(),
        );
      } else {
        return Image.file(
          File(artUri!),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildPlaceholder(),
        );
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.albumGradient(artUri ?? size),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: size * 0.34,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
