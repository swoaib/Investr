import 'package:flutter/material.dart';

enum LessonCategory { foundation, assetClasses, philosophy, strategy }

class Lesson {
  final String id;
  final String title;
  final String description;
  final List<LessonPage> pages;
  final Color color;
  final IconData? icon; // For the list view if needed
  final LessonCategory category;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.pages,
    required this.color,
    required this.category,
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
