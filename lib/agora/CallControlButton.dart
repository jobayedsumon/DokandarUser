import 'package:flutter/material.dart';

class CallControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const CallControlButton({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 32,
        backgroundColor: background,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
