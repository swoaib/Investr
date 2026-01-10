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
            imagePath: 'assets/images/education/stocks_ownership.png',
          ),
          LessonPage(
            title: l10n.theStockMarket,
            description: l10n.theStockMarketDesc,
            imagePath: 'assets/images/education/stock_market.png',
          ),
          LessonPage(
            title: l10n.stockOwnershipHistory,
            description: l10n.stockOwnershipHistoryDesc,
            imagePath: 'assets/images/education/stock_ownership_history.png',
          ),
          LessonPage(
            title: l10n.supportBusinessTitle,
            description: l10n.supportBusinessDesc,
            imagePath: 'assets/images/education/support_business.png',
          ),
          LessonPage(
            title: l10n.stocks101AttributionTitle,
            description: l10n.stocks101AttributionDesc,
            imagePath: 'assets/images/education/stocks_attribution.png',
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
            imagePath: 'assets/images/education/investment_analysis.png',
          ),
          LessonPage(
            title: l10n.theSpeculator,
            description: l10n.theSpeculatorDesc,
            imagePath: 'assets/images/education/speculation_gambling.png',
          ),
          LessonPage(
            title: l10n.valueInvestingTitle,
            description: l10n.valueInvestingDesc,
            imagePath: 'assets/images/education/value_investing.png',
          ),
          LessonPage(
            title: l10n.valueRiskTitle,
            description: l10n.valueRiskDesc,
            imagePath: 'assets/images/education/risk_reward_seesaw.png',
          ),
          LessonPage(
            title: l10n.startupSpeculationTitle,
            description: l10n.startupSpeculationDesc,
            imagePath: 'assets/images/education/strategic_speculation.png',
          ),
        ],
      ),
      Lesson(
        id: 'why_invest',
        title: l10n.whyInvestLessonTitle,
        description: l10n.whyInvestLessonDesc,
        color: const Color(0xFF9C27B0), // Purple for balance
        icon: Icons.question_mark,
        category: LessonCategory.foundation,
        pages: [
          LessonPage(
            title: l10n.inflationBalloonTitle,
            description: l10n.inflationBalloonDesc,
            imagePath: 'assets/images/education/inflation_balloon.png',
          ),
          LessonPage(
            title: l10n.purchasingPowerTitle,
            description: l10n.purchasingPowerDesc,
            imagePath: 'assets/images/education/purchasing_power-2.png',
          ),
          LessonPage(
            title: l10n.cpiBasketTitle,
            description: l10n.cpiBasketDesc,
            imagePath: 'assets/images/education/cpi_basket.png',
          ),
          LessonPage(
            title: l10n.inflationShieldTitle,
            description: l10n.inflationShieldDesc,
            imagePath: 'assets/images/education/inflation_shield.png',
          ),
          LessonPage(
            title: l10n.stocksVsBankTitle,
            description: l10n.stocksVsBankDesc,
            imagePath: 'assets/images/education/compound_graph.png',
          ),
          LessonPage(
            title: l10n.snowballEffect,
            description: l10n.snowballEffectDesc,
            imagePath: 'assets/images/education/compound_snowball.png',
          ),
          LessonPage(
            title: l10n.timeIsKey,
            description: l10n.timeIsKeyDesc,
            imagePath: 'assets/images/education/compound_time.png',
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
            imagePath: 'assets/images/education/investor_choice.png',
          ),
          LessonPage(
            title: l10n.theDefensiveInvestor,
            description: l10n.theDefensiveInvestorDesc,
            imagePath: 'assets/images/education/defensive_investor.png',
          ),
          LessonPage(
            title: l10n.defensiveStrategy,
            description: l10n.defensiveStrategyDesc,
            imagePath: 'assets/images/education/defensive_strategy.png',
          ),
          LessonPage(
            title: l10n.theEnterpriseInvestor,
            description: l10n.theEnterpriseInvestorDesc,
            imagePath: 'assets/images/education/enterprise_investor.png',
          ),
          LessonPage(
            title: l10n.enterpriseStrategy,
            description: l10n.enterpriseStrategyDesc,
            imagePath: 'assets/images/education/enterprise_strategy.png',
          ),
          LessonPage(
            title: l10n.theChoice,
            description: l10n.theChoiceDesc,
            imagePath: 'assets/images/education/intelligent_choice.png',
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
            imagePath: 'assets/images/education/mr_market_meet.png',
          ),
          LessonPage(
            title: l10n.heIsEmotional,
            description: l10n.heIsEmotionalDesc,
            imagePath: 'assets/images/education/mr_market_emotional.png',
          ),
          LessonPage(
            title: l10n.yourAdvantage,
            description: l10n.yourAdvantageDesc,
            imagePath: 'assets/images/education/mr_market_advantage.png',
          ),
          LessonPage(
            title: l10n.intrinsicValue,
            description: l10n.intrinsicValueDesc,
            imagePath: 'assets/images/education/mr_market_intrinsic.png',
          ),
          LessonPage(
            title: l10n.disciplineIsKey,
            description: l10n.disciplineIsKeyDesc,
            imagePath: 'assets/images/education/mr_market_discipline.png',
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
            imagePath: 'assets/images/education/margin_of_safety_secret.png',
          ),
          LessonPage(
            title: l10n.roomForError,
            description: l10n.roomForErrorDesc,
            imagePath:
                'assets/images/education/margin_of_safety_room_for_error.png',
          ),
          LessonPage(
            title: l10n.theEngineersBridge,
            description: l10n.theEngineersBridgeDesc,
            imagePath: 'assets/images/education/margin_of_safety_bridge.png',
          ),
          LessonPage(
            title: l10n.diversification,
            description: l10n.diversificationDesc,
            imagePath:
                'assets/images/education/margin_of_safety_diversification.png',
          ),
          LessonPage(
            title: l10n.conservativeAssumptions,
            description: l10n.conservativeAssumptionsDesc,
            imagePath:
                'assets/images/education/margin_of_safety_conservative.png',
          ),
        ],
      ),
      Lesson(
        id: 'index_funds',
        title: l10n.indexFundsTitle,
        description: l10n.indexFundsDesc,
        color: const Color(0xFF00BCD4),
        icon: Icons.pie_chart,
        category: LessonCategory.philosophy,
        pages: [
          LessonPage(
            title: l10n.whatIsAnIndexFund,
            description: l10n.whatIsAnIndexFundDesc,
            imagePath: 'assets/images/education/index_fund_basket.png',
          ),
          LessonPage(
            title: l10n.instantDiversification,
            description: l10n.instantDiversificationDesc,
            imagePath: 'assets/images/education/ms_diversification.png',
          ),
          LessonPage(
            title: l10n.lowCost,
            description: l10n.lowCostDesc,
            imagePath: 'assets/images/education/low_fees.png',
          ),
          LessonPage(
            title: l10n.marketPerformance,
            description: l10n.marketPerformanceDesc,
            imagePath: 'assets/images/education/market_performance.png',
          ),
        ],
      ),
      Lesson(
        id: 'dollar_cost_averaging',
        title: l10n.dollarCostAveragingTitle,
        description: l10n.dollarCostAveragingDesc,
        color: const Color(0xFF9C27B0),
        icon: Icons.calendar_month,
        category: LessonCategory.philosophy,
        pages: [
          LessonPage(
            title: l10n.whatIsDCA,
            description: l10n.whatIsDCADesc,
            imagePath: 'assets/images/education/dca_calendar.png',
          ),
          LessonPage(
            title: l10n.smoothingTheRide,
            description: l10n.smoothingTheRideDesc,
            imagePath: 'assets/images/education/dca_smoothing.png',
          ),
          LessonPage(
            title: l10n.dcaHistoryCrashTitle,
            description: l10n.dcaHistoryCrashDesc,
            imagePath: 'assets/images/education/dca_crash_1929.png',
          ),
          LessonPage(
            title: l10n.dcaHistoryGrowthTitle,
            description: l10n.dcaHistoryGrowthDesc,
            imagePath: 'assets/images/education/dca_growth.png',
          ),
          LessonPage(
            title: l10n.removeEmotion,
            description: l10n.removeEmotionDesc,
            imagePath: 'assets/images/education/dca_remove_emotion.png',
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
            imagePath: 'assets/images/education/broker_gateway.png',
          ),
          LessonPage(
            title: l10n.popularBrokersTitle,
            description: l10n.popularBrokersDesc,
            customContent: 'broker_list',
          ),
          LessonPage(
            title: l10n.accountTypes,
            description: l10n.accountTypesDesc,
            imagePath: 'assets/images/education/account_types.png',
          ),
          LessonPage(
            title: l10n.etfs,
            description: l10n.etfsDesc,
            imagePath: 'assets/images/education/portfolio_balance.png',
          ),
          LessonPage(
            title: l10n.mutualFunds,
            description: l10n.mutualFundsDesc,
            imagePath: 'assets/images/education/mutual_fund_manager.png',
          ),
          LessonPage(
            title: l10n.ethicalInvesting,
            description: l10n.ethicalInvestingDesc,
            imagePath: 'assets/images/education/esg_investing.png',
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
            imagePath: 'assets/images/education/market_cap_size.png',
          ),
          LessonPage(
            title: l10n.peRatioTitle,
            description: l10n.peRatioImgDesc,
            imagePath: 'assets/images/education/pe_ratio_tag.png',
          ),
          LessonPage(
            title: l10n.dividendYieldTitle,
            description: l10n.dividendYieldDesc,
            imagePath: 'assets/images/education/dividend_yield_tree.png',
          ),
          LessonPage(
            title: l10n.epsTitle,
            description: l10n.epsDesc,
            imagePath: 'assets/images/education/eps_engine.png',
          ),
          LessonPage(
            title: l10n.revenueTitle,
            description: l10n.revenueDesc,
            imagePath: 'assets/images/education/revenue_stream.png',
          ),
          LessonPage(
            title: l10n.grossProfitTitle,
            description: l10n.grossProfitDesc,
            imagePath: 'assets/images/education/gross_profit_pie.png',
          ),
          LessonPage(
            title: l10n.netIncomeTitle,
            description: l10n.netIncomeDesc,
            imagePath: 'assets/images/education/net_income_piggy.png',
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
            imagePath: 'assets/images/education/intrinsic_price_value.png',
          ),
          LessonPage(
            title: l10n.theFormulaDCF,
            description: l10n.theFormulaDCFDesc,
            imagePath: 'assets/images/education/intrinsic_dcf.png',
          ),
          LessonPage(
            title: l10n.stepByStep,
            description: l10n.stepByStepDesc,
            imagePath: 'assets/images/education/intrinsic_formula.png',
          ),
          LessonPage(
            title: l10n.useOurCalculator,
            description: l10n.useOurCalculatorDesc,
            imagePath: 'assets/images/education/intrinsic_conservative.png',
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
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            _getCategoryTitle(lesson.category, l10n),
                            style: Theme.of(context).textTheme.titleMedium
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
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
              child: Icon(
                lesson.icon ?? Icons.school,
                color: lesson.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (progress > 0 && progress < 1.0)
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            const SizedBox(width: 8),
            if (progress >= 1.0)
              const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
            else if (progress > 0.0)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: const Color(
                    0xFF2196F3,
                  ).withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2196F3)),
                ),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
