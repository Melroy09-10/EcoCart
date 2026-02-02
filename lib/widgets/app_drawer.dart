import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/send_notification_screen.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Drawer(
      child: Column(
        children: [
          // ================= USER HEADER =================
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.green,
                    )
                  : null,
            ),
            accountName: Text(user?.displayName ?? 'User'),
            accountEmail: Text(user?.email ?? ''),
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
          ),

          // ================= HOME =================
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
              );
            },
          ),

          // ================= EDIT PROFILE =================
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),

          // ================= SEND NOTIFICATION =================
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Send Notification'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SendNotificationScreen(),
                ),
              );
            },
          ),

          // ================= PRODUCTS =================
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_sharp),
            title: const Text('Admin'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(),
                ),
              );
            },
          ),

          // ================= ORDER HISTORY =================
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              // later
            },
          ),

          const Spacer(),

          // ================= LOGOUT =================
          ListTile(
            leading:
                const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              // Google sign out
              await GoogleSignIn().signOut();

              // Firebase sign out
              await FirebaseAuth.instance.signOut();

              // Clear cart
              cart.clear();

              // Go to login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
