import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sb = Supabase.instance.client;

class PostMediaService {
  Future<String> uploadToStorage(File file, String userId) async {
    final ext = p.extension(file.path);
    final key = '${const Uuid().v4()}$ext';
    final path = '$userId/$key';
    final bytes = await file.readAsBytes();

    await sb.storage.from('posts').uploadBinary(
      path, 
      bytes,
      fileOptions: FileOptions(
        contentType: lookupMimeType(file.path),
        cacheControl: '3600',
        upsert: false,
      ),
    );
    return path;
  }

  String publicUrl(String objectPath) => sb.storage.from('posts').getPublicUrl(objectPath);
  
}