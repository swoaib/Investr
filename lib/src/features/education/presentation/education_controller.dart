import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import '../data/education_service.dart';
import '../domain/lesson.dart';

class EducationController extends ChangeNotifier {
  final EducationService _educationService;
  final Map<String, int> _lessonProgress = {}; // lessonId -> maxPageIndex
  final Map<String, bool> _quizStatus = {}; // lessonId -> passed
  bool _isLoading = true;
  final InAppReview _inAppReview = InAppReview.instance;

  EducationController(this._educationService) {
    _loadProgress();
  }

  // ... existing code ...

  Future<void> transformLessons(List<Lesson> lessons) async {
    _isLoading = true;
    notifyListeners();
    for (final lesson in lessons) {
      final progress = await _educationService.getLessonProgress(lesson.id);
      _lessonProgress[lesson.id] = progress;
      final quizPassed = await _educationService.getQuizStatus(lesson.id);
      _quizStatus[lesson.id] = quizPassed;
    }
    _isLoading = false;
    notifyListeners();
  }

  double getProgress(String lessonId, int totalPages, {bool hasQuiz = false}) {
    // ...
    final index = _lessonProgress[lessonId] ?? 0;

    // If they have seen the last page
    if (index >= totalPages - 1) {
      if (hasQuiz) {
        // If there is a quiz, check if it is passed
        final passed = _quizStatus[lessonId] ?? false;
        return passed
            ? 1.0
            : 0.99; // 0.99 to indicate almost done (read but not passed)
      }
      return 1.0;
    }

    return index / (totalPages - 1);
  }

  bool isQuizPassed(String lessonId) {
    return _quizStatus[lessonId] ?? false;
  }

  Future<void> completeQuiz(String lessonId) async {
    _quizStatus[lessonId] = true;
    notifyListeners();
    await _educationService.saveQuizStatus(lessonId, true);
    await _checkAndRequestReview(lessonId);
  }

  Future<void> _checkAndRequestReview(String lessonId) async {
    if (lessonId == 'why_invest' || lessonId == 'dollar_cost_averaging') {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    }
  }

  // Specific method to get the raw page index for resuming
  // ...

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
