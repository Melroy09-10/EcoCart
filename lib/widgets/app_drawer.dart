import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/profile/edit_profile_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/products/product_list_screen.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔒 Safety check
    if (user == null) {
      return const Drawer(
        child: Center(
          child: Text(
            'User not logged in',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Drawer(
      child: Column(
        children: [
          // ================= USER HEADER =================
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();

              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.green,
                ),
                accountName: Text(
                  data?['name'] ?? 'EcoCart User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(user.email ?? ''),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),

          // ================= PRODUCTS =================
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  ProductListScreen(),
                ),
              );
            },
          ),

          // ================= EDIT PROFILE =================
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),

          // ================= ORDER HISTORY =================
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderHistoryScreen(),
                ),
              );
            },
          ),

          const Spacer(),
          const Divider(),

          // ================= LOGOUT =================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

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
