import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        name.text = doc['name'] ?? '';
        phone.text = doc['phone'] ?? '';
        address.text = doc['address'] ?? '';
      }
    });
  }

  Future<void> save() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'name': name.text,
      'phone': phone.text,
      'address': address.text,
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: address, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
