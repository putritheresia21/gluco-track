import 'package:flutter/material.dart';
import 'package:glucotrack_app/Widget/ContentCard.dart';
import 'package:glucotrack_app/Widget/ContentList.dart';
import 'package:glucotrack_app/pages/detail_article_page.dart';

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
  // Hardcoded articles data with full content
  final List<Map<String, dynamic>> _articles = [
    {
      'id': '1',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'publishedDate': 'Oct 2, 2025',
      'title': 'Exercise: The Medicine You Can\'t Skip.',
      'preview':
          'Stay active to boost both body and brain. Skipping workouts means missing your health.',
      'imageUrl': 'assets/article/exercise.jpg',
      'caption':
          'Stay active to boost both body and brain. Skipping workouts means skipping your health.',
      'content':
          '''When people think about medicine, they usually imagine pills, capsules, or doctor's prescriptions. But here's the truth—one of the most powerful medicines you can ever give your body doesn't come from a pharmacy. It comes from movement. Exercise is the kind of medicine you can't skip, because it works on every part of your health, from your heart and lungs to your mood and mental clarity.

Think about it: just 20–30 minutes of physical activity a day can improve blood circulation, strengthen muscles, and lower the risk of chronic diseases. But it's not just about the body—your brain benefits too. Regular workouts release endorphins, reduce stress, and even sharpen focus. In short, moving your body isn't just about staying fit; it's about staying alive and thriving.

The best part? You don't need an expensive gym membership or fancy equipment to start. A brisk walk, a quick home workout, or even stretching while watching TV can make a real difference. What matters most is consistency. Small steps done daily will bring more results than pushing yourself hard once a month.

So, the next time you feel like skipping exercise, remember this: you're not just skipping a workout—you're skipping an opportunity to invest in your future health. Treat movement like medicine, because your body and brain truly can't function at their best without it.''',
    },
    {
      'id': '2',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'publishedDate': 'Oct 2, 2025',
      'title': 'Healthy Plates, Healthy Life',
      'preview':
          'Balance your meals with color and variety. Small changes bring big results.',
      'imageUrl': 'assets/article/healthy_plates.jpg',
      'caption':
          'Balance your meals with color and variety. Small changes bring big results.',
      'content':
          '''A healthy lifestyle begins with the food you choose every day. Building a balanced plate doesn't have to be complicated—just focus on variety and moderation. By including colorful fruits and vegetables, lean proteins, whole grains, and healthy fats, you can give your body what it needs to stay strong and energized.

The more color you add to your meals, the more nutrients you introduce into your diet. Foods with rich natural colors—like leafy greens, carrots, berries, and peppers—are packed with vitamins, minerals, and antioxidants that support overall well-being. A colorful plate is not only healthier but also more enjoyable to eat.

Portion control is another key to healthy eating. You don't need to remove all your favorite foods, but you can reduce excess sugar, salt, and unhealthy fats. Try using smaller plates, add more vegetables, and avoid overeating by listening to your body's hunger cues.

Small changes, like swapping white rice for brown rice or choosing grilled instead of fried foods, can make a big difference over time. These simple adjustments can support better digestion, stable energy levels, and improved long-term health.

Remember that healthy eating is a journey, not a diet. The goal is progress—not perfection. When you make mindful choices consistently, you'll feel better, stronger, and more confident in your daily life.''',
    },
    {
      'id': '3',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'publishedDate': 'Oct 2, 2025',
      'title': 'Managing Glucose Made Simple',
      'preview':
          'With the right choices, you can stay energized and prevent risks. Your health matters.',
      'imageUrl': 'assets/article/glucose.jpg',
      'caption':
          'With the right choices, you can stay energized and prevent risks. Your health is in your hands.',
      'content':
          '''Managing blood glucose doesn't have to be overwhelming. Understanding how food, physical activity, and daily habits affect your blood sugar can help you make better decisions. With the right approach, you can maintain stable energy levels and reduce the risk of long-term health problems.

Carbohydrates have the biggest impact on blood sugar, so choosing the right type of carbs matters. Whole grains, beans, vegetables, and fruits offer slow and steady energy, unlike sugary snacks and processed foods that cause quick spikes and crashes. Balance is key—not elimination.

Regular physical activity also helps your body use glucose more efficiently. Even simple movements like walking after meals, stretching, or doing light exercise can support healthier glucose levels. Consistency matters more than intensity.

Monitoring your habits can help you understand what works best for your body. Pay attention to how certain meals, stress, or sleep patterns affect your energy. Small lifestyle adjustments can lead to big improvements.

You have the power to take control of your health. By making mindful choices every day, you can protect your well-being, stay active longer, and feel confident in managing your glucose levels.''',
    },
    {
      'id': '4',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'publishedDate': 'Oct 2, 2025',
      'title': 'Your Guide to Everyday Wellness',
      'preview':
          'Practical tips for a healthier, balanced life. Because health is wealth.',
      'imageUrl': 'assets/article/wellness.jpg',
      'caption':
          'Practical tips for a healthier, balanced life. Because health is wealth.',
      'content':
          '''Wellness is not just about avoiding illness—it's about feeling your best physically, mentally, and emotionally. Taking simple steps each day can create a more balanced and fulfilling lifestyle. Healthy habits develop over time, one choice at a time.

Start by fueling your body with nutritious food, staying hydrated, and maintaining regular meal patterns. A balanced diet supports stable moods, better focus, and improved immunity. Small habits like drinking enough water or choosing whole foods can make a big impact.

Mental wellness is just as important as physical health. Taking breaks, practicing mindfulness, journaling, or spending time in nature can help reduce stress and improve emotional balance. Don't forget to rest—quality sleep allows your body and mind to recover.

Movement is another essential part of wellness. Whether it's walking, dancing, yoga, or sports, find activities you enjoy so exercise feels rewarding—not forced. A strong body helps support an active and independent life.

Most importantly, be kind to yourself. Wellness is personal and different for everyone. Progress may be slow, but consistency will help you build habits that last a lifetime. Your health truly is your greatest wealth.''',
    },
    {
      'id': '5',
      'publisherName': 'HealthFocused',
      'publisherAvatar': 'assets/profile/articleprofile.jpg',
      'publishedTime': '1 days ago',
      'publishedDate': 'Oct 2, 2025',
      'title': 'Move Daily, Live Stronger',
      'preview':
          'Simple routines can transform your energy and health. Make movement your daily medicine.',
      'imageUrl': 'assets/article/move_daily.jpg',
      'caption':
          'Simple routines can transform your energy and health. Make movement your daily medicine.',
      'content':
          '''Movement is one of the best gifts you can give your body. Daily physical activity strengthens your muscles, supports heart health, improves flexibility, and boosts mood. You don't need a gym membership—just start where you are.

Simple routines like walking, stretching, or taking the stairs can make a meaningful difference. Even 10 minutes of movement can increase circulation, reduce stiffness, and give you more energy throughout the day.

Exercise also plays an important role in maintaining a healthy weight and managing blood sugar. When your body moves, it uses glucose as fuel, helping maintain balance and prevent spikes. Consistent movement keeps your metabolism active and efficient.

Regular exercise benefits mental health as well. Physical activity triggers the release of endorphins—natural chemicals that reduce stress and increase happiness. Movement can help improve sleep, confidence, and overall mood.

Make exercise something you look forward to, not a chore. Choose activities you enjoy, stay consistent, and celebrate small wins. The more you move, the stronger and healthier you become—one step at a time.''',
    },
  ];

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
              emptyWidget: const Center(
                child: Text(
                  'No articles found',
                  style: TextStyle(
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
