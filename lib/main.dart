import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ CART PROVIDER (GLOBAL & PERSISTENT)
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoCart',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),

        // ✅ AUTH GATE (IMPORTANT)
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // ⏳ Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ✅ Logged in
            if (snapshot.hasData) {
              return const HomeScreen();
            }

            // ❌ Logged out
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
