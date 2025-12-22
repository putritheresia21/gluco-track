import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/register_page.dart';
import 'package:glucotrack_app/services/user_service.dart';
import 'package:glucotrack_app/pages/SocialMedia/Feeds.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: Text(AppLocalizations.of(context)!.social),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PublicFeedPage()));
                },
                child: Text(AppLocalizations.of(context)!.socialMediaFeed)),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.signUp)),
            ElevatedButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.iotConnection)),
            ElevatedButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.testingSocialMedia)),
          ],
        ),
      ),
    );
  }
}
