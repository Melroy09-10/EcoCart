import 'dart:convert';
import 'package:flutter/material.dart';
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

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'size': size,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      size: json['size'],
      quantity: json['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];

  CartProvider() {
    loadCart();
  }

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  void add(ProductModel product, String size) {
    final index = items.indexWhere(
        (e) => e.product.id == product.id && e.size == size);

    if (index >= 0) {
      items[index].quantity++;
    } else {
      items.add(
        CartItem(product: product, size: size, quantity: 1),
      );
    }
    saveCart();
    notifyListeners();
  }

  void increase(CartItem item) {
    item.quantity++;
    saveCart();
    notifyListeners();
  }

  void decrease(CartItem item) {
    item.quantity--;
    if (item.quantity <= 0) {
      items.remove(item);
    }
    saveCart();
    notifyListeners();
  }

  void clear() {
    items.clear();
    saveCart();
    notifyListeners();
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        items.map((e) => jsonEncode(e.toJson())).toList();
    prefs.setStringList('cart_items', data);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('cart_items');
    if (data != null) {
      items =
          data.map((e) => CartItem.fromJson(jsonDecode(e))).toList();
      notifyListeners();
    }
  }
}
