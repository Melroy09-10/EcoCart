import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Providers
import 'providers/cart_provider.dart';

// Screens
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';

// Checkout & Address
import 'checkout/checkout_screen.dart';
import 'checkout/address_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoCart',

        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.green,
        ),

        // ✅ ROUTES (VERY IMPORTANT)
        routes: {
          '/checkout': (context) => const CheckoutScreen(),
          '/address': (context) => const AddressScreen(),
        },

        // ✅ AUTH HANDLING (UNCHANGED)
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData) {
              return const HomeScreen();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
