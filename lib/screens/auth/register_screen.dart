import 'package:flutter/material.dart';

import '../../firebase/firebase_auth_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_web_wrapper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool loading = false;
  bool showPassword = false;

  final Color primaryColor = const Color(0xFF1B5E20);
  final Color bgColor = const Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: AppWebWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: appCard(
              radius: 18,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      appText(
                        "Create Account",
                        size: 24,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(height: 25),

                      // ================= EMAIL =================
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your email address";
                          }
                          if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value.trim())) {
                            return "Please enter a valid email (example: name@gmail.com)";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // ================= PASSWORD =================
                      TextFormField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please create a password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // ================= CONFIRM PASSWORD =================
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          }
                          if (value != passwordController.text) {
                            return "Passwords do not match. Please check again.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // ================= REGISTER BUTTON =================
                      loading
                          ? const CircularProgressIndicator()
                          : appButton(
                              text: "Register",
                              onTap: _register,
                            ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: appText(
                          "Already have an account? Login",
                          color: primaryColor,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= REGISTER =================
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        _showMsg("Account created successfully. Please login.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      _showMsg(_friendlyRegisterError(e.toString()));
    }

    if (mounted) setState(() => loading = false);
  }

  // ================= FRIENDLY ERROR MESSAGES =================
  String _friendlyRegisterError(String error) {
    if (error.contains('email-already-in-use')) {
      return "This email is already registered. Please login instead.";
    } else if (error.contains('invalid-email')) {
      return "The email address entered is not valid.";
    } else if (error.contains('weak-password')) {
      return "Password is too weak. Please choose a stronger one.";
    } else if (error.contains('network-request-failed')) {
      return "No internet connection. Please check your network.";
    } else {
      return "Unable to create account. Please try again later.";
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
