import 'dart:io';
import 'package:flutter/material.dart';

class CachedImageWidget extends StatelessWidget {
  final String? localImagePath;
  final String networkImageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CachedImageWidget({
    super.key,
    this.localImagePath,
    required this.networkImageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Priorité à l'image locale si disponible
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      final file = File(localImagePath!);

      return Image.file(
        file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          // Si l'image locale échoue, essayer l'image réseau
          return _buildNetworkImage();
        },
      );
    }

    // Sinon, utiliser l'image réseau
    return _buildNetworkImage();
  }

  Widget _buildNetworkImage() {
    return Image.network(
      networkImageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                size: width != null ? width! * 0.5 : 50,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                'Image indisponible',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: width != null ? width! * 0.1 : 12,
                ),
              ),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}
