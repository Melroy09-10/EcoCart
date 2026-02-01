import 'package:flutter/material.dart';

class AppWebWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AppWebWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1100, // ideal for ecommerce
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // 📱 MOBILE
        if (width < 600) {
          return SafeArea(
            child: child,
          );
        }

        // 📱 TABLET
        if (width < 1024) {
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: child,
                ),
              ),
            ),
          );
        }

        // 💻 DESKTOP / WEB
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
