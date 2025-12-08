import 'package:flutter/material.dart';
import 'package:glucotrack_app/Widget/article_card.dart';

class NewsPage extends StatefulWidget {
  final bool isInsideSocialPage;
  const NewsPage({super.key, this.isInsideSocialPage = false});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String _searchQuery = '';

  // Hardcoded articles data
  final List<Map<String, dynamic>> _articles = [
    {
      'id': '1',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'title': 'Exercise: The Medicine You Can\'t Skip.',
      'preview':
          'Stay active to boost both body and brain. Skipping workouts means missing your health.',
      'imageUrl': 'assets/article/exercise.jpg',
    },
    {
      'id': '2',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'title': 'Healthy Plates, Healthy Life.',
      'preview':
          'Balance your meals with color and variety. Small changes bring big results.',
      'imageUrl': 'assets/article/healthy_plates.jpg',
    },
    {
      'id': '3',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'title': 'Managing Glucose Made Simple.',
      'preview':
          'With the right choices, you can stay energized and prevent risks. Your health matters.',
      'imageUrl': 'assets/article/glucose.jpg',
    },
    {
      'id': '4',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'title': 'Your Guide to Everyday Wellness.',
      'preview':
          'Practical tips for a healthier, balanced life. Because health is wealth.',
      'imageUrl': 'assets/article/wellness.jpg',
    },
    {
      'id': '5',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'title': 'Move Daily, Live Stronger.',
      'preview':
          'Simple routines can transform your energy and health. Make movement your daily medicine.',
      'imageUrl': 'assets/article/move_daily.jpg',
    },
  ];

  List<Map<String, dynamic>> get _filteredArticles {
    if (_searchQuery.isEmpty) {
      return _articles;
    }
    return _articles.where((article) {
      final title = article['title'].toString().toLowerCase();
      final preview = article['preview'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
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
            child: _filteredArticles.isEmpty
                ? const Center(
                    child: Text(
                      'No articles found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: _filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = _filteredArticles[index];
                      return ArticleCard(
                        publisherName: article['publisherName'],
                        publisherAvatar: article['publisherAvatar'],
                        publishedTime: article['publishedTime'],
                        title: article['title'],
                        preview: article['preview'],
                        imageUrl: article['imageUrl'],
                        onTap: () {
                          // Navigate to article detail page (nti sy tmbh, blm ad)
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ArticleDetailPage(
                          //       articleId: article['id'],
                          //     ),
                          //   ),
                          // );
                        },
                        onMorePressed: () {
                          // Show options menu (nnti ajh lh)
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
