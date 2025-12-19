import 'package:flutter/material.dart';
import '../domain/lesson.dart';
import 'lesson_detail_screen.dart';
import '../../../shared/theme/app_theme.dart';

import 'package:provider/provider.dart';
import '../data/education_service.dart';
import '../presentation/education_controller.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const List<Lesson> lessons = [
    Lesson(
      id: 'stocks_101',
      title: 'Stocks 101',
      description: 'Start your journey here.',
      color: Color(0xFF4CAF50),
      icon: Icons.school,
      pages: [
        LessonPage(
          title: 'What is a Stock?',
          description:
              'A stock represents fractional ownership in a company. When you buy a share, you become a part-owner of that business.',
          imagePath: 'assets/images/education/stocks_ownership.svg',
        ),
        LessonPage(
          title: 'The Stock Market',
          description:
              'The stock market is where buyers and sellers meet to trade shares. Think of it as a supermarket for companies.',
          imagePath: 'assets/images/education/stock_market.svg',
        ),
        LessonPage(
          title: 'Why Invest?',
          description:
              'Investing allows your money to grow over time, helping you beat inflation and build long-term wealth.',
          imagePath: 'assets/images/education/investing_growth.svg',
        ),
      ],
    ),
    Lesson(
      id: 'investing_vs_speculation',
      title: 'Investment vs. Speculation',
      description: 'Understand the difference.',
      color: Color(0xFF2196F3),
      icon: Icons.compare_arrows,
      pages: [
        LessonPage(
          title: 'What is an Investment?',
          description:
              'An operation that, upon thorough analysis, promises safety of principal and an adequate return.',
          imagePath: 'assets/images/education/investment_analysis.svg',
        ),
        LessonPage(
          title: 'The Speculator',
          description:
              'Speculators bet on price movements without understanding the underlying business. It\'s essentially gambling.',
          imagePath: 'assets/images/education/speculation_gambling.svg',
        ),
        LessonPage(
          title: 'Be an Investor',
          description:
              'Focus on the long-term value of the business, not just the ticker price simply moving up and down.',
          imagePath: 'assets/images/education/long_term_value.svg',
        ),
      ],
    ),
    Lesson(
      id: 'mr_market',
      title: 'Mr. Market',
      description: 'The Intelligent Investor concept.',
      color: Color(0xFFFFC107),
      icon: Icons.person,
      pages: [
        LessonPage(
          title: 'Meet Mr. Market',
          description:
              'Imagine a business partner offering to buy your share or sell you his every day at a different price.',
          imagePath: 'assets/images/education/mr_market_meet.svg',
        ),
        LessonPage(
          title: 'He is Emotional',
          description:
              'Some days he is euphoric and sets a high price. Other days he is depressed and sets a low price.',
          imagePath: 'assets/images/education/mr_market_emotional.svg',
        ),
        LessonPage(
          title: 'Your Advantage',
          description:
              'You don\'t have to trade with him inside his mood swings. Use his emotional prices to your advantage.',
          imagePath: 'assets/images/education/mr_market_advantage.svg',
        ),
        LessonPage(
          title: 'Intrinsic Value',
          description:
              'Focus on the intrinsic value of the business. Buy when the price is well below this value, and sell when it is well above.',
          imagePath: 'assets/images/education/mr_market_intrinsic.svg',
        ),
        LessonPage(
          title: 'Discipline is Key',
          description:
              'The investor without a disciplined approach will likely fall victim to Mr. Market\'s irrationality.',
          imagePath: 'assets/images/education/mr_market_discipline.svg',
        ),
      ],
    ),
    Lesson(
      id: 'dollar_cost_averaging',
      title: 'Dollar Cost Averaging',
      description: 'Build wealth through consistency.',
      color: Color(0xFF9C27B0),
      icon: Icons.calendar_month,
      pages: [
        LessonPage(
          title: 'What is DCA?',
          description:
              'Investing a fixed amount of money at regular intervals, regardless of the share price.',
          imagePath: 'assets/images/education/dca_calendar.svg',
        ),
        LessonPage(
          title: 'Smoothing the Ride',
          description:
              'You buy more shares when prices are low and fewer when prices are high, lowering your average cost per share.',
          imagePath: 'assets/images/education/dca_chart.svg',
        ),
        LessonPage(
          title: 'Remove Emotion',
          description:
              'It eliminates the temptation to time the market, preventing emotional decisions during volatility.',
          imagePath: 'assets/images/education/dca_emotion.svg',
        ),
        LessonPage(
          title: 'Consistency Wins',
          description:
              'The key is consistency. Over time, this disciplined approach builds significant wealth.',
          imagePath: 'assets/images/education/dca_growth.svg',
        ),
      ],
    ),
    Lesson(
      id: 'margin_of_safety',
      title: 'Margin of Safety',
      description: 'Risk management strategy.',
      color: Color(0xFFFF5722),
      icon: Icons.shield,
      pages: [
        LessonPage(
          title: 'The Secret',
          description:
              'Benjamin Graham\'s secret to investing: Purchase assets for less than they are truly worth.',
          imagePath: 'assets/images/education/ms_secret.svg',
        ),
        LessonPage(
          title: 'Room for Error',
          description:
              'Buying at a discount protects you if your analysis is slightly off or if the future is unpredictable.',
          imagePath: 'assets/images/education/ms_room_error.svg',
        ),
        LessonPage(
          title: 'The Engineer\'s Bridge',
          description:
              'Like a bridge built to hold 30,000 lbs but only carrying 10,000 lbs, your portfolio needs structural integrity.',
          imagePath: 'assets/images/education/ms_bridge.svg',
        ),
        LessonPage(
          title: 'Diversification',
          description:
              'Margin of safety is also achieved by not putting all your eggs in one basket. Spreading risk protects your capital.',
          imagePath: 'assets/images/education/ms_diversification.svg',
        ),
        LessonPage(
          title: 'Conservative Assumptions',
          description:
              'When valuing a company, always use conservative estimates for growth and profitability to ensure a margin of safety.',
          imagePath: 'assets/images/education/ms_conservative.svg',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          EducationController(EducationService())..transformLessons(lessons),
      child: const _LearnScreenContent(),
    );
  }
}

class _LearnScreenContent extends StatelessWidget {
  const _LearnScreenContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EducationController>();
    final overallProgress = controller.getOverallProgress(LearnScreen.lessons);
    final isOverallCompleted = overallProgress >= 1.0;
    final isOverallInProgress = overallProgress > 0.0 && overallProgress < 1.0;
    final overallProgressColor = isOverallCompleted
        ? AppTheme.primaryGreen
        : isOverallInProgress
        ? Color(0xFF2196F3)
        : AppTheme.textGrey;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.screenPaddingHorizontal,
                AppTheme.screenPaddingVertical,
                AppTheme.screenPaddingHorizontal,
                AppTheme.screenPaddingHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Progress',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${(overallProgress * 100).toInt()}%',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: overallProgressColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: overallProgress,
                            minHeight: 12,
                            backgroundColor: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(
                              overallProgressColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.screenPaddingHorizontal,
                ),
                itemCount: LearnScreen.lessons.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _LessonCard(lesson: LearnScreen.lessons[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    // Watch for updates to repaint when progress changes
    final progress = context.select<EducationController, double>(
      (controller) => controller.getProgress(lesson.id, lesson.pages.length),
    );

    final isCompleted = progress >= 1.0;
    final isInProgress = progress > 0.0 && progress < 1.0;
    final progressColor = isCompleted
        ? AppTheme.primaryGreen
        : isInProgress
        ? Color(0xFF2196F3)
        : AppTheme.textGrey;

    return GestureDetector(
      onTap: () {
        // Pass the existing controller instance to the detail screen
        final controller = context.read<EducationController>();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: controller,
              child: LessonDetailScreen(lesson: lesson),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: lesson.color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lesson.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(lesson.icon ?? Icons.school, color: lesson.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(progressColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              progress >= 1.0 ? Icons.check_circle : Icons.chevron_right,
              color: progress >= 1.0 ? AppTheme.primaryGreen : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
