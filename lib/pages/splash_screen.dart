import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'started_page.dart';
import 'navbar.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Jalankan setelah frame pertama biar context siap untuk Navigator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterDelay();
    });
  }

  Future<void> _navigateAfterDelay() async {
    debugPrint("[Splash] start");
    final prefs = await SharedPreferences.getInstance();
    final isFirstOpen = prefs.getBool('is_first_open') ?? true;

    //tinggalin sedikit delay biar logo sempat tampil
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isFirstOpen) {
      debugPrint("[Splash] first open -> GetStartedPage");
      await prefs.setBool('is_first_open', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
      return;
    }

    // CEK SESSION DARI SUPABASE
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final uid = session.user.id;
      String username = session.user.email?.split('@').first ?? 'User';
      try {
        final row = await Supabase.instance.client
            .from('profiles')
            .select('username')
            .eq('id', uid)
            .maybeSingle();
        final u = (row?['username'] as String?)?.trim();
        if (u != null && u.isNotEmpty) username = u;
      } catch (_) {}
      if (!mounted) return;
      debugPrint("[Splash] has session -> Navbar");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => CustomBottomNav(userId: uid, username: username)),
      );
    } else {
      debugPrint("[Splash] no session -> LoginPage / GetStartedPage");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C7796),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Gluc',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            // pastikan assets/Logo.png ada di pubspec.yaml
            // Transform.translate(offset: Offset(0, 2), child: Image.asset('assets/Logo.png', width: 27, height: 30)),
            SizedBox(width: 8),
            Text('Track',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
