import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/NavbarItem/Navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widget/custom_button.dart';
import '../Widget/InputField.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => LoginPageState();
}

Future<void> saveLoginData(String userId, String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
  await prefs.setString('username', username);
}

class LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;

  void handleLogin() async {
    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.emailPasswordRequired)),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final sb = Supabase.instance.client;

      //buat login iyeahh
      await sb.auth.signInWithPassword(
        email: email,
        password: pass,
      );
      final session = sb.auth.currentSession;
      if (session == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.sessionNotActive)),
        );
        return;
      }
      final uid = session.user.id;

      //ambil dulu ntuhh username dari profiles
      final row = await sb
          .from('profiles')
          .select('username')
          .eq('id', uid)
          .maybeSingle();

      String username = (row?['username'] as String?)?.trim() ?? '';
      if (username.isEmpty) {
        final mail = session.user.email ?? 'User';
        username = mail.split('@').first;
      }

      //ini buat simpan login eluh agar selalu diingat dan dikenang awokawok
      if (rememberMe) {
        await saveLoginData(uid, username);
      }

      // if (!mounted) return;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Welcome back, $username!")),
      // );

      //habis tuhh move on ke home page, jangan gamon!!!
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CustomBottomNav(userId: uid, username: username),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginFailed)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  //enih buat luh pada yang pelupa, lupa password terus mau ganti.
  Future<void> handleForgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterEmailReset)),
      );
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.checkEmailReset)),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C7796),
              Color(0xFF71B2C8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Logo.png', height: 64, width: 64),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.loginToAccount,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),

                CustomInputField(
                  icon: Icons.email,
                  hint: AppLocalizations.of(context)!.enterEmail,
                  controller: emailController,
                  obscureText: false,
                  borderRadius: 24,
                ),
                const SizedBox(height: 16),

                CustomInputField(
                  icon: Icons.lock,
                  hint: AppLocalizations.of(context)!.enterPassword,
                  controller: passwordController,
                  obscureText: true,
                  borderRadius: 24,
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.blue,
                        ),
                        Text(
                          AppLocalizations.of(context)!.rememberMe,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // implementasi Forgot Password soon
                      },
                      child: Text(
                        AppLocalizations.of(context)!.forgotPassword,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 165),

                CustomButton(
                  text: loading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.login,
                  onPressed: handleLogin,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16,
                  width: double.infinity,
                  height: 50,
                  borderRadius: 24,
                  isLoading: loading,
                  isLoadingColor: Colors.black,
                ),
                const SizedBox(height: 16),

                // Sign Up shortcut
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dontHaveAccount,
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
