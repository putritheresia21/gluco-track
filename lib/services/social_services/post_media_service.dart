import 'dart:io';
import 'dart:math';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sb = Supabase.instance.client;

class PostMediaService {
  static const String bucket = 'post-images';

  Future<String> uploadToStorage(File file, String userId) async {
    final user = sb.auth.currentUser;
    if (user == null) {
      throw Exception("Not logged in");
    }
    final uuid = userId ?? user.id;

    final ext = normalizeExt(p.extension(file.path));
    final rand = shortId();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '$uuid/$rand$ext';

    final mime = lookupMimeType(file.path) ?? guessMimeByExt(ext);
    final bytes = await file.readAsBytes();
    
    try {
      await sb.storage.from(bucket).uploadBinary(
        path, 
        bytes,
        fileOptions: FileOptions(
          contentType: mime,
          cacheControl: '3600',
          upsert: false,
        ),
      );
    } on StorageException catch (e) {
      if ((e.statusCode ?? 0) == 409) {
        final altPath = '$uuid/${ts + 1}-${shortId()}$ext';
        await sb.storage.from(bucket).uploadBinary(
          altPath,
          bytes,
          fileOptions: FileOptions(
            contentType: mime,
            cacheControl: '3600',
            upsert: false,
          ),
        );
        return altPath;
      }
      rethrow;
    }
    return path;
  }

  //helpers
  String normalizeExt(String ext) {
    if (ext.isEmpty) return '.jpg';
    ext = ext.toLowerCase();
    if (ext == '.jpeg') return '.jpg';
    return ext;
  }

  String guessMimeByExt(String ext){
    switch(ext){
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  String shortId(){
    final id = const Uuid().v4(). replaceAll('-', '');
    final r = Random();
    final start = r.nextInt(id.length - 8);
    return id.substring(start, start + 8);
  }  
}