import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RoundedSlidableAction extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final Color foregroundColor;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const RoundedSlidableAction({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.foregroundColor = Colors.white,
    this.margin,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () {
          onPressed?.call();
          Slidable.of(context)?.close();
        },
        child: Container(
          color: Colors.transparent, // Hit test behavior
          child: Align(
            alignment: Alignment.center,
            child: Container(
              width: width ?? double.infinity,
              margin: margin ?? const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: foregroundColor),
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: foregroundColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
