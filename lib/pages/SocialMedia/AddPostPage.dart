import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glucotrack_app/services/social_services/PostServices.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'package:glucotrack_app/services/gamification_service/gamification_service.dart';
import 'package:glucotrack_app/utils/AppLayout.dart';
import 'package:glucotrack_app/utils/FontUtils.dart';

class AddPostPage extends StatefulWidget {
  final File? sharedImage;

  const AddPostPage({super.key, this.sharedImage});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  final _svc = PostService();
  final _gamification = GamificationService.instance;
  final List<File> _images = [];
  final ScrollController _imageScrollController = ScrollController();
  bool _loading = false;
  String _replyOption = 'Everyone';

  @override
  void initState() {
    super.initState();
    if (widget.sharedImage != null) {
      _images.add(widget.sharedImage!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageScrollController.dispose();
    super.dispose();
  }

  bool get _hasContent =>
      _controller.text.trim().isNotEmpty || _images.isNotEmpty;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked.map((x) => File(x.path))));
  }

  void _showReplyModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.whoCanReply,
              style: FontUtils.style(
                size: FontSize.xl,
                weight: FontWeightType.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.whoCanReplySubtitle,
              style: FontUtils.style(
                size: FontSize.md,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            _ReplyOption(
              icon: Icons.public,
              title: AppLocalizations.of(context)!.everyone,
              isSelected: _replyOption == 'Everyone',
              onTap: () {
                setState(() => _replyOption = 'Everyone');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _ReplyOption(
              icon: Icons.person_add_alt,
              title: AppLocalizations.of(context)!.followersOnly,
              isSelected: _replyOption == 'Followers Only',
              onTap: () {
                setState(() => _replyOption = 'Followers Only');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClose() async {
    if (_hasContent) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.discardPost,
            style: FontUtils.style(
              size: FontSize.lg,
              weight: FontWeightType.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.discardPostMessage,
            style: FontUtils.style(size: FontSize.md),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: FontUtils.style(
                  size: FontSize.md,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppLocalizations.of(context)!.discard,
                style: FontUtils.style(
                  size: FontSize.md,
                  color: Colors.red,
                  weight: FontWeightType.semibold,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirm == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.writeSomethingOrAddImage)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      if (_images.isEmpty) {
        await _svc.createPost(body: text);
      } else {
        await _svc.createPostWithImages(body: text, files: _images);
      }

      await _gamification.incrementTaskProgress(TaskType.socialPost);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.posted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToPost(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final characterCount = _controller.text.length;

    return AppLayout(
      showHeader: true,
      showBack: false,
      headerBackgroundColor: Colors.white,
      headerForegroundColor: Colors.black,
      elevation: 1,
      headerHeight: 64,
      headerContent: Row(
        children: [
          IconButton(
            onPressed: _loading ? null : _handleClose,
            icon: const Icon(Icons.close, size: 28),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.addNewPost,
              style: FontUtils.style(
                size: FontSize.lg,
                weight: FontWeightType.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _loading || !_hasContent ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5F8D),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF2D5F8D).withOpacity(0.5),
                disabledForegroundColor: Colors.white.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.share,
                      style: FontUtils.style(
                        size: FontSize.md,
                        weight: FontWeightType.semibold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(Icons.person, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.writeSomethingHere,
                              hintStyle: FontUtils.style(
                                size: FontSize.md,
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              filled: false,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: FontUtils.style(size: FontSize.md),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        controller: _imageScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, i) => Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _images[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _images.removeAt(i)),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),          ),          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showReplyModal,
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: 20,
                        color: const Color(0xFF2D5F8D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.whoCanReply,
                        style: FontUtils.style(
                          size: FontSize.sm,
                          color: const Color(0xFF2D5F8D),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  AppLocalizations.of(context)!.characterCount(characterCount),
                  style: FontUtils.style(
                    size: FontSize.sm,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _loading ? null : _pickImages,
                  icon: Icon(
                    Icons.image_outlined,
                    color:
                        _loading ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReplyOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF2D5F8D) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5F8D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2D5F8D),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: FontUtils.style(
                  size: FontSize.md,
                  weight: isSelected
                      ? FontWeightType.semibold
                      : FontWeightType.regular,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2D5F8D),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
