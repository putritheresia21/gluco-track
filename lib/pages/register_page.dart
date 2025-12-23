import 'package:flutter/material.dart';
import 'package:glucotrack_app/Widget/InputField.dart';
import '../Widget/custom_button.dart';
import '../services/Auth_service.dart';
import 'package:glucotrack_app/l10n/app_localizations.dart';
import 'profile.dart';
import 'login_page.dart';
import 'NavbarItem/Navbar.dart';

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
  
  DateTime? selectedBirthDate;
  int calculatedAge = 0;
  String? selectedGender = 'male';

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2C7796),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedBirthDate) {
      setState(() {
        selectedBirthDate = picked;
        calculatedAge = _calculateAge(picked);
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    // Pastikan age minimal 1 jika lahir tahun ini
    return age < 1 ? 1 : age;
  }

  Future<void> handleRegister() async {
    final email = emailController.text.trim();
    var username = usernameController.text.trim();
    final pass = passwordController.text;
    final passConfirm = passwordConfirmController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.emailEmpty)));
      return;
    }

    if (username.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.usernameEmpty)));
      return;
    }

    if (selectedBirthDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.selectBirthDate)));
      return;
    }

    if (passwordController.text != passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.passwordMismatch)));
      return;
    }
    
    setState(() => isLoading = true);

    try {
      print('📝 Register data: age=$calculatedAge, birthDate=$selectedBirthDate, gender=$selectedGender');
      
      final response = await authService.register(
        email: email,
        password: pass,
        username: username,
        birthDate: selectedBirthDate!,
        age: calculatedAge,
        gender: selectedGender ?? 'male',
      );

      if (!mounted) return;

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.registrationFailed)),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.registrationSuccess)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

    } catch (e) {
      if (!mounted) return;
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
                  Text(
                    AppLocalizations.of(context)!.signUp,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.createAccount,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomInputField(
                    icon: Icons.person,
                    hint: AppLocalizations.of(context)!.enterUsername,
                    controller: usernameController,
                    obscureText: false,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 16),

                  CustomInputField(
                    icon: Icons.email,
                    hint: AppLocalizations.of(context)!.enterEmail,
                    controller: emailController,
                    obscureText: false,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 16),

                  // Gender and Birth Date in one row
                  Row(
                    children: [
                      // Gender Dropdown
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.wc, color: Color(0xFF2C7796), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    isExpanded: true,
                                    isDense: true,
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                    items: [
                                      DropdownMenuItem(value: 'male', child: Text(AppLocalizations.of(context)!.male)),
                                      DropdownMenuItem(value: 'female', child: Text(AppLocalizations.of(context)!.female)),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Birth Date Picker
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () => _selectBirthDate(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Color(0xFF2C7796), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                child: Text(
                                  selectedBirthDate == null
                                      ? AppLocalizations.of(context)!.birthDate
                                      : "${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: selectedBirthDate == null
                                        ? Colors.grey[600]
                                        : Colors.black,
                                  ),
                                ),
                                ),
                                if (selectedBirthDate != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2C7796),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$calculatedAge",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomInputField(
                    icon: Icons.lock,
                    hint: AppLocalizations.of(context)!.createPassword,
                    controller: passwordController,
                    obscureText: true,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 16),

                  CustomInputField(
                    icon: Icons.lock_reset,
                    hint: AppLocalizations.of(context)!.confirmPassword,
                    controller: passwordConfirmController,
                    obscureText: true,
                    borderRadius: 24,
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: loading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.signUp,
                    onPressed: isLoading ? null : handleRegister,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.alreadyHaveAccount,
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.login,
                          style: const TextStyle(
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