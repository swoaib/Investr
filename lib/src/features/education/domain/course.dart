import 'package:flutter/material.dart';

class Course {
  final String title;
  final String description;
  final double progress;
  final Color color;

  const Course({
    required this.title,
    required this.description,
    required this.progress,
    required this.color,
  });
}
