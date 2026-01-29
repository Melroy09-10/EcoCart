import 'package:flutter/material.dart';

import '../../firebase/firebase_auth_service.dart';
import '../../widgets/app_widgets.dart';
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
      body: Center(
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

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

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
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    loading
                        ? const CircularProgressIndicator()
                        : appButton(
                            text: "Login",
                            onTap: _login,
                          ),

                    const SizedBox(height: 15),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                            const Size(double.infinity, 50),
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
                            builder: (_) =>
                                const RegisterScreen(),
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
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      _showMsg("Invalid email or password");
    }

    if (mounted) setState(() => loading = false);
  }

Future<void> _googleLogin() async {
  setState(() => loading = true);

  try {
    final user = await _authService.signInWithGoogle();

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _showMsg("Google sign-in cancelled");
    }
  } catch (e) {
    _showMsg(e.toString()); 
    print("GOOGLE LOGIN ERROR: $e");
  }

  if (mounted) setState(() => loading = false);
}

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
