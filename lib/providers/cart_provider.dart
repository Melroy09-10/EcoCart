import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  final String size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'size': size,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: ProductModel.fromMap(
  map['product'],
  map['product']['id'],
),
      size: map['size'],
      quantity: map['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  // ================= ADD =================
  void add(ProductModel product, String size) {
    final index = _items.indexWhere(
      (e) => e.product.id == product.id && e.size == size,
    );

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItem(product: product, size: size, quantity: 1),
      );
    }

    saveCart();
    notifyListeners();
  }

  // ================= INCREASE =================
  void increase(CartItem item) {
    item.quantity++;
    saveCart();
    notifyListeners();
  }

  // ================= DECREASE =================
  void decrease(CartItem item) {
    item.quantity--;
    if (item.quantity <= 0) {
      _items.remove(item);
    }
    saveCart();
    notifyListeners();
  }

  // ================= CLEAR =================
  void clear() {
    _items.clear();
    saveCart();
    notifyListeners();
  }

  // ================= LOCAL SAVE =================
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('cart_items', data);
  }

  // ================= LOAD LOCAL =================
  Future<void> loadCartFromFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('cart_items');

    _items.clear();

    if (data != null) {
      for (final item in data) {
        _items.add(
          CartItem.fromMap(jsonDecode(item)),
        );
      }
    }

    notifyListeners();
  }

  // ================= SAVE ORDER =================
  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('orders')
        .add({
      'userId': user.uid,
      'items': _items.map((e) => e.toMap()).toList(),
      'total': totalPrice,
      'createdAt': Timestamp.now(),
    });

    clear();
  }
}
