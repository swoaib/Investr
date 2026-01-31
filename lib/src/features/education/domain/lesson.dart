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
  final Quiz? quiz;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.pages,
    required this.color,
    required this.category,
    this.icon,
    this.quiz,
  });

  double get progress => 0.0; // Placeholder for now
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class Quiz {
  final String title;
  final List<QuizQuestion> questions;

  const Quiz({required this.title, required this.questions});
}

class LessonPage {
  final String title;
  final String description;
  final String? imagePath;
  final IconData? icon; // Fallback if no image
  final String? customContent; // 'broker_list', etc.

  const LessonPage({
    required this.title,
    required this.description,
    this.imagePath,
    this.icon,
    this.customContent,
  });
}
