import 'package:flutter/material.dart';
import '../domain/lesson.dart';
import 'lesson_detail_screen.dart';
import '../../../shared/theme/app_theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  static const List<Lesson> lessons = [
    Lesson(
      title: 'Stocks 101',
      description: 'Start your journey here.',
      color: Color(0xFF4CAF50),
      icon: Icons.school,
      pages: [
        LessonPage(
          title: 'What is a Stock?',
          description:
              'A stock represents fractional ownership in a company. When you buy a share, you become a part-owner of that business.',
          imagePath: 'assets/images/education/stocks_ownership.png',
        ),
        LessonPage(
          title: 'The Stock Market',
          description:
              'The stock market is where buyers and sellers meet to trade shares. Think of it as a supermarket for companies.',
          imagePath: 'assets/images/education/stock_market.png',
        ),
        LessonPage(
          title: 'Why Invest?',
          description:
              'Investing allows your money to grow over time, helping you beat inflation and build long-term wealth.',
          imagePath: 'assets/images/education/investing_growth.png',
        ),
      ],
    ),
    Lesson(
      title: 'Investment vs. Speculation',
      description: 'Understand the difference.',
      color: Color(0xFF2196F3),
      icon: Icons.compare_arrows,
      pages: [
        LessonPage(
          title: 'What is an Investment?',
          description:
              'An operation that, upon thorough analysis, promises safety of principal and an adequate return.',
          imagePath: 'assets/images/education/investment_analysis.png',
        ),
        LessonPage(
          title: 'The Speculator',
          description:
              'Speculators bet on price movements without understanding the underlying business. It\'s essentially gambling.',
          imagePath: 'assets/images/education/speculation_gambling.png',
        ),
        LessonPage(
          title: 'Be an Investor',
          description:
              'Focus on the long-term value of the business, not just the ticker price simply moving up and down.',
          imagePath: 'assets/images/education/long_term_value.png',
        ),
      ],
    ),
    Lesson(
      title: 'Mr. Market',
      description: 'The Intelligent Investor concept.',
      color: Color(0xFFFFC107),
      icon: Icons.person,
      pages: [
        LessonPage(
          title: 'Meet Mr. Market',
          description:
              'Imagine a business partner offering to buy your share or sell you his every day at a different price.',
          icon: Icons.face,
        ),
        LessonPage(
          title: 'He is Emotional',
          description:
              'Some days he is euphoric and sets a high price. Other days he is depressed and sets a low price.',
          icon: Icons.mood_bad,
        ),
        LessonPage(
          title: 'Your Advantage',
          description:
              'You don\'t have to trade with him inside his mood swings. Use his emotional prices to your advantage.',
          icon: Icons.thumbs_up_down,
        ),
        LessonPage(
          title: 'Intrinsic Value',
          description:
              'Focus on the intrinsic value of the business. Buy when the price is well below this value, and sell when it is well above.',
          icon: Icons.balance,
        ),
        LessonPage(
          title: 'Discipline is Key',
          description:
              'The investor without a disciplined approach will likely fall victim to Mr. Market\'s irrationality.',
          icon: Icons.psychology,
        ),
      ],
    ),
    Lesson(
      title: 'Dollar Cost Averaging',
      description: 'Build wealth through consistency.',
      color: Color(0xFF9C27B0),
      icon: Icons.calendar_month,
      pages: [
        LessonPage(
          title: 'What is DCA?',
          description:
              'Investing a fixed amount of money at regular intervals, regardless of the share price.',
          icon: Icons.update,
        ),
        LessonPage(
          title: 'Smoothing the Ride',
          description:
              'You buy more shares when prices are low and fewer when prices are high, lowering your average cost per share.',
          icon: Icons.waterfall_chart,
        ),
        LessonPage(
          title: 'Remove Emotion',
          description:
              'It eliminates the temptation to time the market, preventing emotional decisions during volatility.',
          icon: Icons.timer_off,
        ),
        LessonPage(
          title: 'Consistency Wins',
          description:
              'The key is consistency. Over time, this disciplined approach builds significant wealth.',
          icon: Icons.savings,
        ),
      ],
    ),
    Lesson(
      title: 'Margin of Safety',
      description: 'Risk management strategy.',
      color: Color(0xFFFF5722),
      icon: Icons.shield,
      pages: [
        LessonPage(
          title: 'The Secret',
          description:
              'Benjamin Graham\'s secret to investing: Purchase assets for less than they are truly worth.',
          icon: Icons.local_offer,
        ),
        LessonPage(
          title: 'Room for Error',
          description:
              'Buying at a discount protects you if your analysis is slightly off or if the future is unpredictable.',
          icon: Icons.shield,
        ),
        LessonPage(
          title: 'The Engineer\'s Bridge',
          description:
              'Like a bridge built to hold 30,000 lbs but only carrying 10,000 lbs, your portfolio needs structural integrity.',
          icon: Icons.construction,
        ),
        LessonPage(
          title: 'Diversification',
          description:
              'Margin of safety is also achieved by not putting all your eggs in one basket. Spreading risk protects your capital.',
          icon: Icons.pie_chart,
        ),
        LessonPage(
          title: 'Conservative Assumptions',
          description:
              'When valuing a company, always use conservative estimates for growth and profitability to ensure a margin of safety.',
          icon: Icons.trending_down,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Learn',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.screenPaddingHorizontal,
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
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
                  // Progress indicator can be implemented later when we have state
                  LinearProgressIndicator(
                    value: 0.0, // Default 0 for now
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(lesson.color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
