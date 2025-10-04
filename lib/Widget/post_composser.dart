import 'package:flutter/material.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';

class PostComposer extends StatefulWidget {
  const PostComposer({super.key, this.onPosted});
  final VoidCallback? onPosted;

  @override
  State<PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposer> {
  final _controller = TextEditingController();
  final _svc = PostService();
  bool _loading = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis sesuatu dulu…')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _svc.createPost(body: text);
      _controller.clear();
      widget.onPosted?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal post: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Apa yang kamu pikirkan?',
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
