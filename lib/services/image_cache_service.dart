import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ImageCacheService {
  static final ImageCacheService instance = ImageCacheService._init();

  ImageCacheService._init();

  // Répertoire pour stocker les images
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/cached_images');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    return imageDir.path;
  }

  // Télécharger et sauvegarder une image
  Future<String?> downloadAndSaveImage(String imageUrl, int productId) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final String fileExtension = path.extension(imageUrl).split('?')[0];
        final String fileName =
            'product_$productId${fileExtension.isEmpty ? '.jpg' : fileExtension}';

        final String dirPath = await _localPath;
        final String filePath = '$dirPath/$fileName';

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('✅ Image sauvegardée: $filePath');
        return filePath;
      } else {
        print('❌ Erreur HTTP ${response.statusCode} pour $imageUrl');
      }
    } catch (e) {
      print('❌ Erreur téléchargement image: $e');
    }

    return null;
  }

  // Vérifier si une image existe localement
  Future<bool> imageExists(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return false;
    final file = File(localPath);
    return await file.exists();
  }

  // Supprimer une image
  Future<void> deleteImage(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Image supprimée: $localPath');
      }
    } catch (e) {
      print('Erreur suppression image: $e');
    }
  }

  // Nettoyer toutes les images en cache
  Future<void> clearAllImages() async {
    try {
      final String dirPath = await _localPath;
      final dir = Directory(dirPath);

      if (await dir.exists()) {
        await dir.delete(recursive: true);
        print('🗑️ Cache d\'images nettoyé');
      }
    } catch (e) {
      print('Erreur nettoyage cache: $e');
    }
  }

  // Obtenir la taille du cache en Mo
  Future<double> getCacheSizeMB() async {
    try {
      final String dirPath = await _localPath;
      final dir = Directory(dirPath);

      if (!await dir.exists()) return 0;

      int totalSize = 0;
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize / (1024 * 1024); // Convertir en Mo
    } catch (e) {
      print('Erreur calcul taille cache: $e');
      return 0;
    }
  }
}
