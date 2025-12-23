import 'package:flutter/material.dart';
import 'package:glucotrack_app/Widget/ContentCard.dart';
import 'package:glucotrack_app/Widget/ContentList.dart';
import 'package:glucotrack_app/pages/detail_article_page.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';

class NewsPage extends StatefulWidget {
  final bool isInsideSocialPage;
  final String searchQuery;

  const NewsPage({
    super.key,
    this.isInsideSocialPage = false,
    this.searchQuery = '',
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<Map<String, dynamic>> get _articles {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'id': '1',
        'publisherName': 'HealthFocused',
        'publisherAvatar': 'assets/profile/articleprofile.jpg',
        'publishedTime': l10n.daysAgo(1),
        'publishedDate': 'Oct 2, 2025',
        'title': l10n.article1Title,
        'preview': l10n.article1Preview,
        'imageUrl': 'assets/article/exercise.jpg',
        'caption': l10n.article1Caption,
        'content': l10n.article1Content,
      },
      {
        'id': '2',
        'publisherName': 'HealthFocused',
        'publisherAvatar': 'assets/profile/articleprofile.jpg',
        'publishedTime': l10n.daysAgo(1),
        'publishedDate': 'Oct 2, 2025',
        'title': l10n.article2Title,
        'preview': l10n.article2Preview,
        'imageUrl': 'assets/article/healthy_plates.jpg',
        'caption': l10n.article2Caption,
        'content': l10n.article2Content,
      },
      {
        'id': '3',
        'publisherName': 'HealthFocused',
        'publisherAvatar': 'assets/profile/articleprofile.jpg',
        'publishedTime': l10n.daysAgo(1),
        'publishedDate': 'Oct 2, 2025',
        'title': l10n.article3Title,
        'preview': l10n.article3Preview,
        'imageUrl': 'assets/article/glucose.jpg',
        'caption': l10n.article3Caption,
        'content': l10n.article3Content,
      },
      {
        'id': '4',
        'publisherName': 'HealthFocused',
        'publisherAvatar': 'assets/profile/articleprofile.jpg',
        'publishedTime': l10n.daysAgo(1),
        'publishedDate': 'Oct 2, 2025',
        'title': l10n.article4Title,
        'preview': l10n.article4Preview,
        'imageUrl': 'assets/article/wellness.jpg',
        'caption': l10n.article4Caption,
        'content': l10n.article4Content,
      },
      {
        'id': '5',
        'publisherName': 'HealthFocused',
        'publisherAvatar': 'assets/profile/articleprofile.jpg',
        'publishedTime': l10n.daysAgo(1),
        'publishedDate': 'Oct 2, 2025',
        'title': l10n.article5Title,
        'preview': l10n.article5Preview,
        'imageUrl': 'assets/article/move_daily.jpg',
        'caption': l10n.article5Caption,
        'content': l10n.article5Content,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredArticles {
    if (widget.searchQuery.isEmpty) {
      return _articles;
    }
    return _articles.where((article) {
      final title = article['title'].toString().toLowerCase();
      final preview = article['preview'].toString().toLowerCase();
      final query = widget.searchQuery.toLowerCase();
      return title.contains(query) || preview.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          // Articles List
          Expanded(
            child: ContentList<Map<String, dynamic>>(
              items: _filteredArticles,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              emptyWidget: Center(
                child: Text(
                  AppLocalizations.of(context)!.noArticlesFound,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              itemBuilder: (context, article, index) {
                return ContentCard(
                  headerAvatar: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(article['publisherAvatar']),
                  ),
                  headerTitle: article['publisherName'],
                  headerSubtitle: article['publishedTime'],
                  headerTrailing: IconButton(
                    onPressed: () {
                      // Show options menu (nnti ajh lh)
                    },
                    icon: const Icon(Icons.more_vert, color: Colors.black54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  title: article['title'],
                  body: article['preview'],
                  imageUrls: [article['imageUrl']],
                  imageInline: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(
                          articleId: article['id'],
                          title: article['title'],
                          publisherName: article['publisherName'],
                          publishedDate: article['publishedDate'],
                          imageUrl: article['imageUrl'],
                          caption: article['caption'],
                          content: article['content'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
