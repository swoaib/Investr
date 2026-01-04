import 'package:flutter/material.dart';
import '../domain/lesson.dart';
import 'lesson_detail_screen.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
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
        category: LessonCategory.foundation,
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
            title: l10n.stockOwnershipHistory,
            description: l10n.stockOwnershipHistoryDesc,
            imagePath: 'assets/images/education/stock_ownership_history.png',
          ),
        ],
      ),
      Lesson(
        id: 'investing_vs_speculation',
        title: l10n.investingVsSpeculationTitle,
        description: l10n.investingVsSpeculationDesc,
        color: const Color(0xFF2196F3),
        icon: Icons.compare_arrows,
        category: LessonCategory.foundation,
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
            title: l10n.valueInvestingTitle,
            description: l10n.valueInvestingDesc,
            imagePath: 'assets/images/education/long_term_value.svg',
          ),
          LessonPage(
            title: l10n.valueRiskTitle,
            description: l10n.valueRiskDesc,
            imagePath: 'assets/images/education/risk_reward_seesaw.svg',
          ),
          LessonPage(
            title: l10n.startupSpeculationTitle,
            description: l10n.startupSpeculationDesc,
            imagePath: 'assets/images/education/strategic_speculation.png',
          ),
        ],
      ),
      Lesson(
        id: 'power_of_compounding',
        title: l10n.powerOfCompoundingTitle,
        description: l10n.powerOfCompoundingDesc,
        color: const Color(0xFFFF9800),
        icon: Icons.trending_up,
        category: LessonCategory.foundation,
        pages: [
          LessonPage(
            title: l10n.snowballEffect,
            description: l10n.snowballEffectDesc,
            imagePath: 'assets/images/education/compound_snowball.svg',
          ),
          LessonPage(
            title: l10n.timeIsKey,
            description: l10n.timeIsKeyDesc,
            imagePath: 'assets/images/education/compound_time.svg',
          ),
          LessonPage(
            title: l10n.exponentialGrowth,
            description: l10n.exponentialGrowthDesc,
            imagePath: 'assets/images/education/compound_graph.svg',
          ),
        ],
      ),
      Lesson(
        id: 'stocks_vs_bonds',
        title: l10n.stocksVsBondsTitle,
        description: l10n.stocksVsBondsDesc,
        color: const Color(0xFF9C27B0), // Purple for balance
        icon: Icons.scale,
        category: LessonCategory.assetClasses,
        pages: [
          LessonPage(
            title: l10n.stocksForGrowth,
            description: l10n.stocksForGrowthDesc,
            imagePath: 'assets/images/education/stocks_growth.svg',
          ),
          LessonPage(
            title: l10n.bondsForStability,
            description: l10n.bondsForStabilityDesc,
            imagePath: 'assets/images/education/bonds_stability.svg',
          ),
          LessonPage(
            title: l10n.riskVsReward,
            description: l10n.riskVsRewardDesc,
            imagePath: 'assets/images/education/risk_reward_seesaw.svg',
          ),
          LessonPage(
            title: l10n.theIdealMix,
            description: l10n.theIdealMixDesc,
            imagePath: 'assets/images/education/portfolio_balance.svg',
          ),
        ],
      ),
      Lesson(
        id: 'inflation',
        title: l10n.inflationTitle,
        description: l10n.inflationDesc,
        color: const Color(0xFFE91E63), // Pink/Red for warning/urgent concept
        icon: Icons.price_change,
        category: LessonCategory.foundation,
        pages: [
          LessonPage(
            title: l10n.inflationBalloonTitle,
            description: l10n.inflationBalloonDesc,
            imagePath: 'assets/images/education/inflation_balloon.svg',
          ),
          LessonPage(
            title: l10n.purchasingPowerTitle,
            description: l10n.purchasingPowerDesc,
            imagePath: 'assets/images/education/purchasing_power.svg',
          ),
          LessonPage(
            title: l10n.cpiBasketTitle,
            description: l10n.cpiBasketDesc,
            imagePath: 'assets/images/education/cpi_basket.svg',
          ),
          LessonPage(
            title: l10n.inflationShieldTitle,
            description: l10n.inflationShieldDesc,
            imagePath: 'assets/images/education/inflation_shield.svg',
          ),
        ],
      ),
      Lesson(
        id: 'defensive_vs_enterprise',
        title: l10n.defensiveVsEnterpriseTitle,
        description: l10n.defensiveVsEnterpriseDesc,
        color: const Color(0xFF009688),
        icon: Icons.balance,
        category: LessonCategory.philosophy,
        pages: [
          LessonPage(
            title: l10n.twoPaths,
            description: l10n.twoPathsDesc,
            imagePath: 'assets/images/education/investor_choice.svg',
          ),
          LessonPage(
            title: l10n.theDefensiveInvestor,
            description: l10n.theDefensiveInvestorDesc,
            imagePath: 'assets/images/education/defensive_investor.svg',
          ),
          LessonPage(
            title: l10n.defensiveStrategy,
            description: l10n.defensiveStrategyDesc,
            imagePath: 'assets/images/education/defensive_strategy.svg',
          ),
          LessonPage(
            title: l10n.theEnterpriseInvestor,
            description: l10n.theEnterpriseInvestorDesc,
            imagePath: 'assets/images/education/enterprise_investor.svg',
          ),
          LessonPage(
            title: l10n.enterpriseStrategy,
            description: l10n.enterpriseStrategyDesc,
            imagePath: 'assets/images/education/enterprise_strategy.svg',
          ),
          LessonPage(
            title: l10n.theChoice,
            description: l10n.theChoiceDesc,
            imagePath: 'assets/images/education/intelligent_choice.svg',
          ),
        ],
      ),
      Lesson(
        id: 'mr_market',
        title: l10n.mrMarketTitle,
        description: l10n.mrMarketDesc,
        color: const Color(0xFFFFC107),
        icon: Icons.person,
        category: LessonCategory.philosophy,
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
        category: LessonCategory.philosophy,
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
        id: 'dollar_cost_averaging',
        title: l10n.dollarCostAveragingTitle,
        description: l10n.dollarCostAveragingDesc,
        color: const Color(0xFF9C27B0),
        icon: Icons.calendar_month,
        category: LessonCategory.strategy,
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
          LessonPage(
            title: l10n.dcaHistoryCrashTitle,
            description: l10n.dcaHistoryCrashDesc,
            imagePath: 'assets/images/education/dca_crash_1929.png',
          ),
          LessonPage(
            title: l10n.dcaHistoryGrowthTitle,
            description: l10n.dcaHistoryGrowthDesc,
            imagePath: 'assets/images/education/dca_growth_1929.png',
          ),
        ],
      ),
      Lesson(
        id: 'index_funds',
        title: l10n.indexFundsTitle,
        description: l10n.indexFundsDesc,
        color: const Color(0xFF00BCD4),
        icon: Icons.pie_chart,
        category: LessonCategory.assetClasses,
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
        id: 'how_to_invest',
        title: l10n.howToInvestTitle,
        description: l10n.howToInvestDesc,
        color: const Color(0xFF795548), // Brown for solid foundation/wallet
        icon: Icons.account_balance_wallet,
        category: LessonCategory.strategy,
        pages: [
          LessonPage(
            title: l10n.theBroker,
            description: l10n.theBrokerDesc,
            imagePath: 'assets/images/education/broker_gateway.svg',
          ),
          LessonPage(
            title: l10n.accountTypes,
            description: l10n.accountTypesDesc,
            imagePath: 'assets/images/education/account_types.svg',
          ),
          LessonPage(
            title: l10n.etfs,
            description: l10n.etfsDesc,
            imagePath: 'assets/images/education/etf_basket.svg',
          ),
          LessonPage(
            title: l10n.mutualFunds,
            description: l10n.mutualFundsDesc,
            imagePath: 'assets/images/education/mutual_fund_manager.svg',
          ),
          LessonPage(
            title: l10n.ethicalInvesting,
            description: l10n.ethicalInvestingDesc,
            imagePath: 'assets/images/education/esg_investing.svg',
          ),
        ],
      ),
      Lesson(
        id: 'understanding_metrics',
        title: l10n.understandingMetricsTitle,
        description: l10n.understandingMetricsDesc,
        color: const Color(0xFF607D8B), // Blue Grey for data/analytics
        icon: Icons.analytics,
        category: LessonCategory.strategy,
        pages: [
          LessonPage(
            title: l10n.marketCapTitle,
            description: l10n.marketCapDesc,
            imagePath: 'assets/images/education/market_cap_size.svg',
          ),
          LessonPage(
            title: l10n.peRatioTitle,
            description: l10n.peRatioImgDesc,
            imagePath: 'assets/images/education/pe_ratio_tag.svg',
          ),
          LessonPage(
            title: l10n.dividendYieldTitle,
            description: l10n.dividendYieldDesc,
            imagePath: 'assets/images/education/dividend_yield_tree.svg',
          ),
          LessonPage(
            title: l10n.epsTitle,
            description: l10n.epsDesc,
            imagePath: 'assets/images/education/eps_engine.svg',
          ),
        ],
      ),
      Lesson(
        id: 'calculating_intrinsic_value',
        title: l10n.calcIntrinsicValueTitle,
        description: l10n.calcIntrinsicValueDesc,
        color: const Color(0xFF673AB7),
        icon: Icons.calculate,
        category: LessonCategory.strategy,
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

    // Grouping logic for initial sort
    lessons.sort((a, b) => a.category.index.compareTo(b.category.index));

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
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  left: AppTheme.screenPaddingHorizontal,
                  right: AppTheme.screenPaddingHorizontal,
                  bottom: CustomBottomNavigationBar.contentBottomPadding,
                ),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  final showHeader =
                      index == 0 ||
                      lesson.category != lessons[index - 1].category;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showHeader)
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            _getCategoryTitle(lesson.category, l10n),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LessonCard(lesson: lesson),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(LessonCategory category, AppLocalizations l10n) {
    switch (category) {
      case LessonCategory.foundation:
        return l10n.moduleFoundation;
      case LessonCategory.assetClasses:
        return l10n.moduleAssetClasses;
      case LessonCategory.philosophy:
        return l10n.modulePhilosophy;
      case LessonCategory.strategy:
        return l10n.moduleStrategy;
    }
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
