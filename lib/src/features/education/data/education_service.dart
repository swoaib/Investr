import 'package:shared_preferences/shared_preferences.dart';

class EducationService {
  static const String _progressKeyPrefix = 'lesson_progress_';

  Future<void> saveLessonProgress(String lessonId, int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_progressKeyPrefix$lessonId';

    // Only update if the new page index is greater than the stored one
    final currentProgress = prefs.getInt(key) ?? 0;
    if (pageIndex > currentProgress) {
      await prefs.setInt(key, pageIndex);
    }
  }

  static const String _quizPassedKeyPrefix = 'quiz_passed_';

  Future<int> getLessonProgress(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_progressKeyPrefix$lessonId') ?? 0;
  }

  Future<void> saveQuizStatus(String lessonId, bool passed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_quizPassedKeyPrefix$lessonId', passed);
  }

  Future<bool> getQuizStatus(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_quizPassedKeyPrefix$lessonId') ?? false;
  }
}
