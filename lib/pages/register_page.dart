import 'package:flutter/material.dart';
import 'package:glucotrack_app/Widget/custom_input_field.dart';
import 'package:glucotrack_app/pages/home_page.dart';
import '../Widget/custom_button.dart';
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
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email tidak boleh kosong")));
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

      //kalau berhasil register, langsung cus ke login page TP MASIH ERROR JING
      if (response != null && response.user != null) {
        //final uid = response?.user?.id;
        // final uid = response.user!.id;
        // final displayName = response.user!.email?.split('@').first ?? 'User';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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

                  CustomInputField(
                    icon: Icons.email,
                    hint: "Enter your email",
                    controller: emailController,
                    obscureText: false,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 16),

                  CustomInputField(
                    icon: Icons.lock,
                    hint: "Create a password",
                    controller: passwordController,
                    obscureText: true,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 16),

                  CustomInputField(
                    icon: Icons.lock_reset,
                    hint: "Confirm password",
                    controller: passwordConfirmController,
                    obscureText: true,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 150),

                  CustomButton(
                    text: loading ? "Loading..." : "Sign Up",
                    onPressed: handleRegister,
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
