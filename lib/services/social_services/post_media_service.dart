// post_media_service.dart
import 'dart:io';
import 'dart:math';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sb = Supabase.instance.client;

class PostMediaService {
  static const String bucket = 'post-images'; 

  Future<String> uploadToStorage(File file, [String? userId]) async {
    final user = sb.auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    final uid = userId ?? user.id;

    final ext = _normalizeExt(p.extension(file.path));
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = _shortId();
    final path = '$uid/$ts-$rand$ext';

    final mime = lookupMimeType(file.path) ?? _guessMimeByExt(ext);
    final bytes = await file.readAsBytes();

    await sb.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: mime,
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return path; 
  }

  String publicUrl(String storagePath) {
    final url = sb.storage.from(bucket).getPublicUrl(storagePath);
    print('DEBUG: Generated public URL: $url');
    return url;
  }

  Future<String> signedUrl(String storagePath, {int expiresIn = 60}) =>
      sb.storage.from(bucket).createSignedUrl(storagePath, expiresIn);

  // helpers
  String _normalizeExt(String ext) {
    if (ext.isEmpty) return '.jpg';
    ext = ext.toLowerCase();
    if (ext == '.jpeg') return '.jpg';
    return ext;
  }

  String _guessMimeByExt(String ext) {
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  String _shortId() {
    final id = const Uuid().v4().replaceAll('-', '');
    final r = Random();
    final start = r.nextInt(id.length - 8);
    return id.substring(start, start + 8);
  }
}
