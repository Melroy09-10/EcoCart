import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

/// =======================
/// TEXT WIDGET
/// =======================
Widget appText(
  String text, {
  double size = 14,
  FontWeight weight = FontWeight.normal,
  Color color = Colors.black,
  TextAlign align = TextAlign.start,
}) {
  return Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
    ),
  );
}

/// =======================
/// TEXT FIELD WIDGET
/// =======================
Widget appTextField({
  required TextEditingController controller,
  required String hint,
  IconData? icon,
  bool isPassword = false,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

/// =======================
/// BUTTON WIDGET
/// =======================
Widget appButton({
  required String text,
  required VoidCallback onTap,
  Color color = Colors.green,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Text(text),
    ),
  );
}

/// =======================
/// CARD WIDGET
/// =======================
Widget appCard({
  required Widget child,
  double radius = 14,
}) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
    elevation: 4,
    child: child,
  );
}

/// =======================
/// PRODUCT CARD WIDGET
/// =======================
Widget productCard({
  required String imageUrl,
  required String name,
  required double price,
  required VoidCallback onAddToCart,
}) {
  return appCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(14),
          ),
          child: Image.network(
            imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appText(name, weight: FontWeight.bold, size: 16),
              const SizedBox(height: 4),
              appText("₹$price", size: 15),
              const SizedBox(height: 10),
              appButton(
                text: "Add to Cart",
                onTap: onAddToCart,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

//CarouselSlider//

Widget appImageSlider(List<String> images) {
  return CarouselSlider(
    options: CarouselOptions(
      height: 180,
      autoPlay: true,
      enlargeCenterPage: true,
      viewportFraction: 0.9,
    ),
    items: images.map((image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          image,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }).toList(),
  );
}