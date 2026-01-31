import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../domain/lesson.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final void Function(bool isPassed) onFinish;

  const QuizScreen({required this.quiz, required this.onFinish, super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  void _handleOptionTap(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (index ==
          widget.quiz.questions[_currentQuestionIndex].correctOptionIndex) {
        _score++;
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuizResultSheet(
        score: _score,
        total: widget.quiz.questions.length,
        onFinish: widget.onFinish,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final question = widget.quiz.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.questionCount(
                  _currentQuestionIndex + 1,
                  widget.quiz.questions.length,
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question.question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ...List.generate(question.options.length, (index) {
                final isSelected = _selectedOptionIndex == index;
                final isCorrect = index == question.correctOptionIndex;
                final showResult = _isAnswered && (isSelected || isCorrect);

                Color? borderColor;
                Color? backgroundColor;

                if (showResult) {
                  if (isCorrect) {
                    borderColor = AppTheme.primaryGreen;
                    backgroundColor = AppTheme.primaryGreen.withValues(
                      alpha: 0.1,
                    );
                  } else if (isSelected) {
                    borderColor = Theme.of(context).colorScheme.error;
                    backgroundColor = Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _handleOptionTap(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: borderColor ?? Theme.of(context).dividerColor,
                          width: showResult ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: backgroundColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (showResult)
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect
                                  ? AppTheme.primaryGreen
                                  : Theme.of(context).colorScheme.error,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (_isAnswered) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedOptionIndex == question.correctOptionIndex
                            ? l10n.correct
                            : l10n.incorrect,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  _selectedOptionIndex ==
                                      question.correctOptionIndex
                                  ? AppTheme.primaryGreen
                                  : Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestionIndex == widget.quiz.questions.length - 1
                        ? l10n.finish
                        : l10n.quizNext,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizResultSheet extends StatelessWidget {
  final int score;
  final int total;
  final void Function(bool isPassed) onFinish;

  const _QuizResultSheet({
    required this.score,
    required this.total,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPassed = score == total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isPassed
                  ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPassed ? Icons.emoji_events : Icons.close,
              size: 48,
              color: isPassed
                  ? AppTheme.primaryGreen
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isPassed ? l10n.quizCompleted : l10n.quizFailed,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isPassed ? l10n.quizScore(score, total) : l10n.quizFailMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close local sheet
                onFinish(isPassed); // Pass result to parent
              },
              style: isPassed
                  ? null
                  : ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
              child: Text(isPassed ? l10n.finish : l10n.tryAgain),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
