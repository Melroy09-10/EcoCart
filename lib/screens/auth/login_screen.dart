import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../firebase/firebase_auth_service.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_web_wrapper.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                      Icon(
                        Icons.shopping_bag,
                        size: 48,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 10),
                      appText(
                        "EcoCart",
                        size: 26,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      appText("Login to continue"),
                      const SizedBox(height: 30),

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
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters long";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // ================= LOGIN BUTTON =================
                      loading
                          ? const CircularProgressIndicator()
                          : appButton(
                              text: "Login",
                              onTap: _login,
                            ),

                      const SizedBox(height: 15),

                      // ================= GOOGLE LOGIN =================
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        icon: Image.network(
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/512px-Google_%22G%22_logo.svg.png",
                          height: 20,
                        ),
                        label: const Text("Continue with Google"),
                        onPressed: loading ? null : _googleLogin,
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: appText(
                          "Don’t have an account? Register",
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

  // ================= EMAIL LOGIN =================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null && mounted) {
        await context
            .read<CartProvider>()
            .loadCartFromFirestore();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      _showMsg(_friendlyAuthError(e.toString()));
    }

    if (mounted) setState(() => loading = false);
  }

  // ================= GOOGLE LOGIN =================
  Future<void> _googleLogin() async {
    setState(() => loading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        await context
            .read<CartProvider>()
            .loadCartFromFirestore();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        _showMsg("Google sign-in was cancelled.");
      }
    } catch (e) {
      _showMsg("Unable to sign in with Google. Please try again.");
    }

    if (mounted) setState(() => loading = false);
  }

  // ================= FRIENDLY ERROR MESSAGES =================
  String _friendlyAuthError(String error) {
    if (error.contains('user-not-found')) {
      return "No account found with this email. Please register first.";
    } else if (error.contains('wrong-password')) {
      return "Incorrect password. Please try again.";
    } else if (error.contains('invalid-email')) {
      return "The email address entered is not valid.";
    } else if (error.contains('user-disabled')) {
      return "This account has been disabled. Please contact support.";
    } else if (error.contains('network-request-failed')) {
      return "No internet connection. Please check your network.";
    } else {
      return "Something went wrong. Please try again later.";
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
