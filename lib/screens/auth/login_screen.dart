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
                        Icons.shopping_cart,
                        size: 48,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 10),

                      appText(
                        "EcoCart Grocery",
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
                        validator: _validateEmail,
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
                        validator: _validatePassword,
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

  // ================= VALIDATIONS =================

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email (example@gmail.com)";
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
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
        await context.read<CartProvider>().loadCart();

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
        await context.read<CartProvider>().loadCart();

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

  // ================= FRIENDLY ERROR HANDLING =================
  String _friendlyAuthError(String error) {
    final err = error.toLowerCase();

    if (err.contains('user-not-found')) {
      return "No account found with this email.";
    } else if (err.contains('wrong-password')) {
      return "Incorrect password. Please try again.";
    } else if (err.contains('invalid-email')) {
      return "Invalid email address.";
    } else if (err.contains('user-disabled')) {
      return "This account has been disabled.";
    } else if (err.contains('network-request-failed')) {
      return "No internet connection.";
    } else {
      return "Login failed. Please try again.";
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
