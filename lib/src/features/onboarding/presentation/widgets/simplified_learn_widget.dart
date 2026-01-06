import 'package:flutter/material.dart';
import 'package:investr/src/shared/theme/app_theme.dart';
import 'package:investr/l10n/app_localizations.dart';

class SimplifiedLearnWidget extends StatelessWidget {
  const SimplifiedLearnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.myProgress,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                '35%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.35,
              minHeight: 6,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(height: 24),
          _buildLessonItem(
            context,
            icon: Icons.school,
            color: const Color(0xFF4CAF50),
            title: AppLocalizations.of(context)!.stocks101Title,
            subtitle: AppLocalizations.of(context)!.basicsOfOwnership,
            isCompleted: true,
          ),
          const SizedBox(height: 12),
          _buildLessonItem(
            context,
            icon: Icons.show_chart,
            color: const Color(0xFF2196F3),
            title: AppLocalizations.of(context)!.whyInvestLessonTitle,
            subtitle: AppLocalizations.of(context)!.beatingInflation,
            progress: 0.6,
          ),
          const SizedBox(height: 12),
          _buildLessonItem(
            context,
            icon: Icons.shield,
            color: const Color(0xFFFF5722),
            title: AppLocalizations.of(context)!.marginOfSafetyTitle,
            subtitle: AppLocalizations.of(context)!.riskManagement,
            isLocked: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    bool isCompleted = false,
    bool isLocked = false,
    double? progress,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isLocked ? Colors.grey : color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey : null,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (isCompleted)
          const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20)
        else if (isLocked)
          const Icon(Icons.lock, color: Colors.grey, size: 18)
        else if (progress != null)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
      ],
    );
  }
}
