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
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: -5,
                ),
              ]
            : null,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.surfaceVariant, AppColors.surfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.album_rounded,
          size: size * 0.4,
          color: AppColors.textTertiary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
