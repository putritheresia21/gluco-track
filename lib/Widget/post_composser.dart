import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';

class PostComposer extends StatefulWidget {
  const PostComposer({super.key, this.onPosted});
  final VoidCallback? onPosted;

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  final _svc = PostService();
  final List<File> _images = [];
  bool _loading = false;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked.map((x) => File(x.path))));
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Tulis sesuatu dulu")));
      return;
    }
    setState(() => _loading = true);
    try {
      if (_images.isEmpty) {
        await _svc.createPost(body: text);
      } else {
        await _svc.createPostWithImages(body: text, files: _images);
      }
      _controller.clear();
      _images.clear();
      widget.onPosted?.call();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Posted!")));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal post: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Apa yang kamu pikirkan?",
                border: InputBorder.none,
              ),
            ),
            if (_images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                itemCount: _images.length,
                itemBuilder: (_, i) => Stack(
                  children: [
                    Image.file(_images[i], fit: BoxFit.cover),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(i)),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _loading ? null : _pickImages,
                  icon: const Icon(Icons.photo),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text("Post"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
