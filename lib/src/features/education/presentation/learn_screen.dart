import 'package:flutter/material.dart';
import '../domain/lesson.dart';
import 'lesson_detail_screen.dart';
import '../../../shared/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../data/education_service.dart';
import '../presentation/education_controller.dart';
import 'package:investr/l10n/app_localizations.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  List<Lesson> _getLessons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      Lesson(
        id: 'stocks_101',
        title: l10n.stocks101Title,
        description: l10n.stocks101Desc,
        color: const Color(0xFF4CAF50),
        icon: Icons.school,
        pages: [
          LessonPage(
            title: l10n.whatIsAStock,
            description: l10n.whatIsAStockDesc,
            imagePath: 'assets/images/education/stocks_ownership.svg',
          ),
          LessonPage(
            title: l10n.theStockMarket,
            description: l10n.theStockMarketDesc,
            imagePath: 'assets/images/education/stock_market.svg',
          ),
          LessonPage(
            title: l10n.whyInvest,
            description: l10n.whyInvestDesc,
            imagePath: 'assets/images/education/investing_growth.svg',
          ),
        ],
      ),
      Lesson(
        id: 'investing_vs_speculation',
        title: l10n.investingVsSpeculationTitle,
        description: l10n.investingVsSpeculationDesc,
        color: const Color(0xFF2196F3),
        icon: Icons.compare_arrows,
        pages: [
          LessonPage(
            title: l10n.whatIsAnInvestment,
            description: l10n.whatIsAnInvestmentDesc,
            imagePath: 'assets/images/education/investment_analysis.svg',
          ),
          LessonPage(
            title: l10n.theSpeculator,
            description: l10n.theSpeculatorDesc,
            imagePath: 'assets/images/education/speculation_gambling.svg',
          ),
          LessonPage(
            title: l10n.beAnInvestor,
            description: l10n.beAnInvestorDesc,
            imagePath: 'assets/images/education/long_term_value.svg',
          ),
        ],
      ),
      Lesson(
        id: 'mr_market',
        title: l10n.mrMarketTitle,
        description: l10n.mrMarketDesc,
        color: const Color(0xFFFFC107),
        icon: Icons.person,
        pages: [
          LessonPage(
            title: l10n.meetMrMarket,
            description: l10n.meetMrMarketDesc,
            imagePath: 'assets/images/education/mr_market_meet.svg',
          ),
          LessonPage(
            title: l10n.heIsEmotional,
            description: l10n.heIsEmotionalDesc,
            imagePath: 'assets/images/education/mr_market_emotional.svg',
          ),
          LessonPage(
            title: l10n.yourAdvantage,
            description: l10n.yourAdvantageDesc,
            imagePath: 'assets/images/education/mr_market_advantage.svg',
          ),
          LessonPage(
            title: l10n.intrinsicValue,
            description: l10n.intrinsicValueDesc,
            imagePath: 'assets/images/education/mr_market_intrinsic.svg',
          ),
          LessonPage(
            title: l10n.disciplineIsKey,
            description: l10n.disciplineIsKeyDesc,
            imagePath: 'assets/images/education/mr_market_discipline.svg',
          ),
        ],
      ),
      Lesson(
        id: 'margin_of_safety',
        title: l10n.marginOfSafetyTitle,
        description: l10n.marginOfSafetyDesc,
        color: const Color(0xFFFF5722),
        icon: Icons.shield,
        pages: [
          LessonPage(
            title: l10n.theSecret,
            description: l10n.theSecretDesc,
            imagePath: 'assets/images/education/ms_secret.svg',
          ),
          LessonPage(
            title: l10n.roomForError,
            description: l10n.roomForErrorDesc,
            imagePath: 'assets/images/education/ms_room_error.svg',
          ),
          LessonPage(
            title: l10n.theEngineersBridge,
            description: l10n.theEngineersBridgeDesc,
            imagePath: 'assets/images/education/ms_bridge.svg',
          ),
          LessonPage(
            title: l10n.diversification,
            description: l10n.diversificationDesc,
            imagePath: 'assets/images/education/ms_diversification.svg',
          ),
          LessonPage(
            title: l10n.conservativeAssumptions,
            description: l10n.conservativeAssumptionsDesc,
            imagePath: 'assets/images/education/ms_conservative.svg',
          ),
        ],
      ),
      Lesson(
        id: 'index_funds',
        title: l10n.indexFundsTitle,
        description: l10n.indexFundsDesc,
        color: const Color(0xFF00BCD4),
        icon: Icons.pie_chart,
        pages: [
          LessonPage(
            title: l10n.whatIsAnIndexFund,
            description: l10n.whatIsAnIndexFundDesc,
            imagePath: 'assets/images/education/index_fund_basket.svg',
          ),
          LessonPage(
            title: l10n.instantDiversification,
            description: l10n.instantDiversificationDesc,
            imagePath: 'assets/images/education/diversification.svg',
          ),
          LessonPage(
            title: l10n.lowCost,
            description: l10n.lowCostDesc,
            imagePath: 'assets/images/education/low_fees.svg',
          ),
          LessonPage(
            title: l10n.marketPerformance,
            description: l10n.marketPerformanceDesc,
            imagePath: 'assets/images/education/market_performance.svg',
          ),
        ],
      ),
      Lesson(
        id: 'dollar_cost_averaging',
        title: l10n.dollarCostAveragingTitle,
        description: l10n.dollarCostAveragingDesc,
        color: const Color(0xFF9C27B0),
        icon: Icons.calendar_month,
        pages: [
          LessonPage(
            title: l10n.whatIsDCA,
            description: l10n.whatIsDCADesc,
            imagePath: 'assets/images/education/dca_calendar.svg',
          ),
          LessonPage(
            title: l10n.smoothingTheRide,
            description: l10n.smoothingTheRideDesc,
            imagePath: 'assets/images/education/dca_chart.svg',
          ),
          LessonPage(
            title: l10n.removeEmotion,
            description: l10n.removeEmotionDesc,
            imagePath: 'assets/images/education/dca_emotion.svg',
          ),
          LessonPage(
            title: l10n.consistencyWins,
            description: l10n.consistencyWinsDesc,
            imagePath: 'assets/images/education/dca_growth.svg',
          ),
        ],
      ),
      Lesson(
        id: 'calculating_intrinsic_value',
        title: l10n.calcIntrinsicValueTitle,
        description: l10n.calcIntrinsicValueDesc,
        color: const Color(0xFF673AB7),
        icon: Icons.calculate,
        pages: [
          LessonPage(
            title: l10n.priceVsValue,
            description: l10n.priceVsValueDesc,
            imagePath: 'assets/images/education/intrinsic_price_value.svg',
          ),
          LessonPage(
            title: l10n.theFormulaDCF,
            description: l10n.theFormulaDCFDesc,
            imagePath: 'assets/images/education/intrinsic_dcf.svg',
          ),
          LessonPage(
            title: l10n.stepByStep,
            description: l10n.stepByStepDesc,
            imagePath: 'assets/images/education/intrinsic_formula.svg',
          ),
          LessonPage(
            title: l10n.useOurCalculator,
            description: l10n.useOurCalculatorDesc,
            imagePath: 'assets/images/education/intrinsic_conservative.svg',
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _getLessons(context);
    return ChangeNotifierProvider(
      create: (_) =>
          EducationController(EducationService())..transformLessons(lessons),
      child: _LearnScreenContent(lessons: lessons),
    );
  }
}

class _LearnScreenContent extends StatelessWidget {
  final List<Lesson> lessons;
  const _LearnScreenContent({required this.lessons});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<EducationController>();
    final overallProgress = controller.getOverallProgress(lessons);
    final isOverallCompleted = overallProgress >= 1.0;
    final isOverallInProgress = overallProgress > 0.0 && overallProgress < 1.0;
    final overallProgressColor = isOverallCompleted
        ? AppTheme.primaryGreen
        : isOverallInProgress
        ? const Color(0xFF2196F3)
        : AppTheme.textGrey;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.screenPaddingHorizontal,
                AppTheme.screenPaddingVertical,
                AppTheme.screenPaddingHorizontal,
                AppTheme.screenPaddingVertical,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.learnTitle,
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
                              l10n.overallProgress,
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
                padding: const EdgeInsets.only(
                  left: AppTheme.screenPaddingHorizontal,
                  right: AppTheme.screenPaddingHorizontal,
                  bottom: 100,
                ),
                itemCount: lessons.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _LessonCard(lesson: lessons[index]);
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
        ? const Color(0xFF2196F3)
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
