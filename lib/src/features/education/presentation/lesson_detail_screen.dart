import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../shared/theme/app_theme.dart';
import '../domain/lesson.dart';
import 'education_controller.dart';
import 'quiz_screen.dart';
import 'widgets/popular_brokers_widget.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({required this.lesson, super.key});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize PageController with stored progress
    final initialPage = context.read<EducationController>().getRawProgress(
      widget.lesson.id,
    );
    // If completed (reached the last page), restart from 0
    // Otherwise resume from where we left off
    if (initialPage >= widget.lesson.pages.length - 1) {
      _currentPage = 0;
    } else {
      _currentPage = initialPage;
    }
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Update progress
    context.read<EducationController>().updateProgress(widget.lesson.id, index);
  }

  void _nextPage() {
    if (_currentPage < widget.lesson.pages.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      HapticFeedback.lightImpact();

      if (widget.lesson.quiz != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              quiz: widget.lesson.quiz!,
              onFinish: () {
                context.read<EducationController>().completeQuiz(
                  widget.lesson.id,
                );
                Navigator.of(context).pop(); // Close quiz
                Navigator.of(context).pop(); // Close lesson
              },
            ),
          ),
        );
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.lesson.pages.length,
                itemBuilder: (context, index) {
                  return _LessonPageView(page: widget.lesson.pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      widget.lesson.pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryGreen
                              : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Next/Done Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == widget.lesson.pages.length - 1
                          ? (widget.lesson.quiz != null
                                ? AppLocalizations.of(context)!.startQuiz
                                : AppLocalizations.of(context)!.done)
                          : AppLocalizations.of(context)!.next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonPageView extends StatelessWidget {
  final LessonPage page;

  const _LessonPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    if (page.customContent == 'broker_list') {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
        child: Column(
          children: [
            if (page.title.isNotEmpty) ...[
              Text(
                page.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            if (page.description.isNotEmpty) ...[
              Text(
                page.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
            const Expanded(child: PopularBrokersWidget()),
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.imagePath != null)
            page.imagePath!.endsWith('.svg')
                ? SvgPicture.asset(
                    page.imagePath!,
                    height: 300,
                    fit: BoxFit.contain,
                  )
                : Image.asset(page.imagePath!, height: 300, fit: BoxFit.contain)
          else if (page.icon != null)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(page.icon, size: 80, color: AppTheme.primaryGreen),
            )
          else
            const SizedBox.shrink(),

          const SizedBox(height: 32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
