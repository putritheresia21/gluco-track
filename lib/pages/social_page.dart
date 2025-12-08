import 'package:flutter/material.dart';
import 'package:glucotrack_app/Widget/social_header.dart';
import 'package:glucotrack_app/pages/SocialMedia/feeds.dart';
import 'package:glucotrack_app/pages/news_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          /// Header now controls tab
          SocialHeader(
            currentPage: _currentIndex == 0 ? "feed" : "news",
            onFeedPressed: () => setState(() => _currentIndex = 0),
            onNewsPressed: () => setState(() => _currentIndex = 1),
          ),

          /// Pages stay alive (IndexedStack keeps state)
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                PublicFeedPage(isInsideSocialPage: true),
                NewsPage(isInsideSocialPage: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
