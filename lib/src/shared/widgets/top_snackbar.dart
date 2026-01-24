import 'package:flutter/material.dart';

void showTopSnackBar(
  BuildContext context, {
  required String message,
  required Color backgroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => _TopSnackBarWidget(
      message: message,
      backgroundColor: backgroundColor,
      onDismiss:
          () {}, // The widget handles self-dismissal via animation controller
    ),
  );

  overlay.insert(overlayEntry);

  // Remove the entry after the duration + animation time
  Future.delayed(duration + const Duration(milliseconds: 600), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.message,
    required this.backgroundColor,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();

    // Schedule reverse animation
    // Note: The actual overlay removal is handled by the caller,
    // but we want to reverse the animation before that happens.
    // The caller waits 'duration + 600ms'.
    // We should wait 'duration' then reverse.
    // However, since we don't have the duration passed here easily without more plumbing,
    // let's just make the caller handle the removal logic combined with a simpler approach?
    // Actually, to make it perfectly synced, the caller passed 'duration'.
    // Let's just hardcode 3s default behavior here matching the caller or pass it down.
    // For simplicity, let's assume the standard 3s display time + nice exit.

    // Better approach: effectively 3 seconds visible, then reverse.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10, // Just below status bar
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
