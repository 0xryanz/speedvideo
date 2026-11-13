import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../config/app_config.dart';

/// Network artwork with a branded loading state and a graceful offline
/// fallback. Every poster/backdrop in the app goes through this widget.
class NetworkArtwork extends StatelessWidget {
  const NetworkArtwork({
    required this.path,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fallbackLabel,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final String? fallbackLabel;

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.assetUrl(path);
    if (url.isEmpty) return _fallback();
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _fallback(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }

  Widget _fallback() {
    final label = (fallbackLabel?.isNotEmpty ?? false)
        ? fallbackLabel!.characters.first.toUpperCase()
        : 'S';
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF101010)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'BarlowCondensed',
          fontSize: (height ?? 80) * 0.28,
          fontWeight: FontWeight.w800,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
