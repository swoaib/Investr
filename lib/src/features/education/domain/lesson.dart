import 'package:flutter/material.dart';

class Lesson {
  final String title;
  final String description;
  final List<LessonPage> pages;
  final Color color;
  final IconData? icon; // For the list view if needed

  const Lesson({
    required this.title,
    required this.description,
    required this.pages,
    required this.color,
    this.icon,
  });

  double get progress => 0.0; // Placeholder for now
}

class LessonPage {
  final String title;
  final String description;
  final String? imagePath;
  final IconData? icon; // Fallback if no image

  const LessonPage({
    required this.title,
    required this.description,
    this.imagePath,
    this.icon,
  });
}
