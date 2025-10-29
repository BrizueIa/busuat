import 'package:flutter/material.dart';

class RecenterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RecenterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.explore, color: Colors.orange, size: 28),
        ),
      ),
    );
  }
}
