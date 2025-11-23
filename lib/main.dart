import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/navbar.dart';
import '../pages/splash_screen.dart';

// const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
// const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlucoTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.blueAccent),
      ),
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root({super.key});

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  String? username;
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      setState(() {
        userId = null;
        username = null;
        isLoading = false;
      });
      return;
    }

    final uid = session.user.id;
    final res = await Supabase.instance.client
        .from('profiles')
        .select('username')
        .eq('id', uid)
        .maybeSingle();

    setState(() {
      userId = uid;
      username = res?['username'] as String?;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const SplashScreen();
    } else {
      return CustomBottomNav(
        userId: userId!,
        username: username ?? 'Anonymous',
      );
    }
  }
}
