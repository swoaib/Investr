import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RoundedSlidableAction extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final Color foregroundColor;
  final EdgeInsetsGeometry? margin;

  const RoundedSlidableAction({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.foregroundColor = Colors.white,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: onPressed != null ? (context) => onPressed!() : null,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      child: Container(
        margin: margin ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
