import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final Widget? headerAvatar;
  final String? headerTitle;
  final String? headerSubtitle;
  final Widget? headerTrailing;
  final VoidCallback? onHeaderTap;

  // Content section
  final String? title;
  final String? body;
  final Widget? customContent;
  final List<String>? imageUrls;
  final VoidCallback? onImageTap;
  final bool
      imageInline; // true = beside text (article style), false = below text (post style)

  // Footer section
  final List<Widget>? actions;
  final Widget? footer;

  // Card styling
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;

  const ContentCard({
    super.key,
    // Header
    this.headerAvatar,
    this.headerTitle,
    this.headerSubtitle,
    this.headerTrailing,
    this.onHeaderTap,
    // Content
    this.title,
    this.body,
    this.customContent,
    this.imageUrls,
    this.onImageTap,
    this.imageInline = false,
    // Footer
    this.actions,
    this.footer,
    // Styling
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                if (headerAvatar != null ||
                    headerTitle != null ||
                    headerSubtitle != null ||
                    headerTrailing != null)
                  _buildHeader(),

                // Spacing after header
                if ((headerAvatar != null ||
                        headerTitle != null ||
                        headerSubtitle != null ||
                        headerTrailing != null) &&
                    (title != null ||
                        body != null ||
                        customContent != null ||
                        imageUrls != null))
                  const SizedBox(height: 12),

                // Content Section
                if (customContent != null)
                  customContent!
                else if (imageInline &&
                    imageUrls != null &&
                    imageUrls!.isNotEmpty)
                  _buildInlineContent()
                else ...[
                  _buildContent(),
                  // Images Section (below content)
                  if (imageUrls != null && imageUrls!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildImages(),
                  ],
                ],

                // Footer Section
                if (actions != null || footer != null) ...[
                  const SizedBox(height: 12),
                  if (footer != null)
                    footer!
                  else if (actions != null)
                    Row(
                      children: actions!
                          .map((action) => Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: action,
                              ))
                          .toList(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: onHeaderTap,
      child: Row(
        children: [
          if (headerAvatar != null) ...[
            headerAvatar!,
            const SizedBox(width: 12),
          ],
          if (headerTitle != null || headerSubtitle != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (headerTitle != null)
                    Text(
                      headerTitle!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  if (headerSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      headerSubtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (headerTrailing != null) headerTrailing!,
        ],
      ),
    );
  }

  Widget _buildInlineContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
              if (title != null && body != null) const SizedBox(height: 8),
              if (body != null)
                Text(
                  body!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Article Image (fixed size, beside text)
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: onImageTap,
            child: _buildInlineImage(imageUrls!.first),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.3,
            ),
          ),
        if (title != null && body != null) const SizedBox(height: 8),
        if (body != null)
          Text(
            body!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildImages() {
    if (imageUrls!.length == 1) {
      return _buildSingleImage(imageUrls!.first);
    } else {
      return _buildImageGrid();
    }
  }

  Widget _buildSingleImage(String url) {
    final isAsset = url.startsWith('assets/');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: onImageTap,
        child: isAsset
            ? Image.asset(
                url,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade500,
                    ),
                  );
                },
              )
            : Image.network(
                url,
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 100,
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade500,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imageUrls!.length == 2 ? 2 : 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: imageUrls!.length > 4 ? 4 : imageUrls!.length,
        itemBuilder: (context, index) {
          final url = imageUrls![index];
          final isAsset = url.startsWith('assets/');

          return GestureDetector(
            onTap: onImageTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                isAsset
                    ? Image.asset(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade500,
                            ),
                          );
                        },
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade500,
                            ),
                          );
                        },
                      ),
                if (index == 3 && imageUrls!.length > 4)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text(
                      '+${imageUrls!.length - 4}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInlineImage(String url) {
    final isAsset = url.startsWith('assets/');

    return isAsset
        ? Image.asset(
            url,
            width: 100,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 70,
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade500,
                ),
              );
            },
          )
        : Image.network(
            url,
            width: 100,
            height: 70,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 100,
                height: 70,
                color: Colors.grey.shade100,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 70,
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey.shade500,
                ),
              );
            },
          );
  }
}
