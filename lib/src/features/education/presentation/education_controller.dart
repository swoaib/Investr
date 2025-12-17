import 'package:flutter/material.dart';
import '../data/education_service.dart';
import '../domain/lesson.dart';

class EducationController extends ChangeNotifier {
  final EducationService _educationService;
  final Map<String, int> _lessonProgress = {}; // lessonId -> maxPageIndex
  bool _isLoading = true;

  EducationController(this._educationService) {
    _loadProgress();
  }

  bool get isLoading => _isLoading;

  Future<void> _loadProgress() async {
    // In a real app, we might want to pass the list of lesson IDs to load
    // But for now, we'll load them lazily or we can assume we know the IDs
    // Since we don't have the list of lessons injected here yet, we will just set loading to false
    // and let the UI trigger storage reads or we can just rely on getProgress if it was synchronous.
    // However, SharedPreferences is async.

    // Better approach: When the controller initializes, we can't know all IDs unless passed.
    // So we will expose a method to initialize progress for a list of lessons.
    _isLoading = false;
    notifyListeners();
  }

  Future<void> transformLessons(List<Lesson> lessons) async {
    _isLoading = true;
    notifyListeners();
    for (final lesson in lessons) {
      final progress = await _educationService.getLessonProgress(lesson.id);
      _lessonProgress[lesson.id] = progress;
    }
    _isLoading = false;
    notifyListeners();
  }

  double getProgress(String lessonId, int totalPages) {
    // Progress is (completed pages) / (total pages - 1)
    // Because page 0 is 0% (start), last page is 100% (done)
    // Actually, "Done" button is on the last page.
    // Let's say:
    // page 0 of 3 -> 0/3 = 0%
    // page 1 of 3 -> 1/3 = 33%
    // page 2 of 3 -> 2/3 = 66%
    // finshed -> 3/3 = 100%
    // But we only track "max page reached".
    // If user reached last page (index totalPages - 1), that's technically 100% if they read it.
    // Let's treat "reaching the last page" as effectively completed for visual simplicity,
    // or we can add a specific "completed" flag.
    // For now: (current page index + 1) / totalPages is a bit aggressive if just started.
    // Let's map 0..totalPages-1 to 0..1
    if (totalPages <= 1) return 1.0;

    // If stored index is totalPages - 1 (the last page), show 100%
    // Otherwise show index / (totalPages - 1)

    final index = _lessonProgress[lessonId] ?? 0;
    // If they have seen the last page, it's 100%
    if (index >= totalPages - 1) return 1.0;

    return index / (totalPages - 1);
  }

  // Specific method to get the raw page index for resuming
  int getRawProgress(String lessonId) {
    return _lessonProgress[lessonId] ?? 0;
  }

  Future<void> updateProgress(String lessonId, int pageIndex) async {
    final currentMax = _lessonProgress[lessonId] ?? 0;
    if (pageIndex > currentMax) {
      _lessonProgress[lessonId] = pageIndex;
      notifyListeners();
      await _educationService.saveLessonProgress(lessonId, pageIndex);
    }
  }

  double getOverallProgress(List<Lesson> lessons) {
    if (lessons.isEmpty) return 0.0;
    double totalProgress = 0.0;
    for (final lesson in lessons) {
      totalProgress += getProgress(lesson.id, lesson.pages.length);
    }
    return totalProgress / lessons.length;
  }
}
