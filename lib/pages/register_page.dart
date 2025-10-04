import 'package:flutter/material.dart';
import 'package:glucotrack_app/pages/home_page.dart';
import '../services/Auth_service.dart';
import 'profile_page.dart';
import 'login_page.dart';
import '../pages/navbar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  final AuthService authService = AuthService();
  bool isLoading = false;

  Future<void> handleRegister() async {
    final email = emailController.text.trim();
    var username = usernameController.text.trim();
    final pass = passwordController.text;
    final passConfirm = passwordConfirmController.text;

    //validasi email dulu, jangan sampe kosong. awas aja sampe kosonggg
    if (email.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email tidak boleh kosong")));
      return;
    }
    //validasi konfirmasi pasword
    if (passwordController.text != passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password confirmation does not match")));
      return;
    }
    setState(() => isLoading = true);

    try {
      final response = await authService.register(
        email: email,
        password: pass,
        username: username,
      );

      if (response != null && response.user != null) {
        //final uid = response?.user?.id;
        final uid = response.user!.id;
        final displayName = response.user!.email?.split('@').first ?? 'User';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
          builder: (context) => HomePage(),
        )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Image.asset(
                    'assets/Logo.png',
                    height: 64,
                    width: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sign UP",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Create your new account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  buildInputField(
                    icon: Icons.email,
                    hint: "Enter your email",
                    contoller: emailController,
                    obscureText: false,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  buildInputField(
                    icon: Icons.lock,
                    hint: "Create a password",
                    contoller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  buildInputField(
                    icon: Icons.lock,
                    hint: "Confirm password",
                    contoller: passwordConfirmController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 150),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Shortcut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildInputField({
  required IconData icon,
  required String hint,
  required TextEditingController contoller,
  required bool obscureText,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: TextField(
      controller: contoller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    ),
  );
}
