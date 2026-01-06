import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/theme/app_theme.dart';
import 'package:investr/l10n/app_localizations.dart';

class SimplifiedValuationWidget extends StatelessWidget {
  const SimplifiedValuationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardColor.withValues(alpha: 0.9),
            Theme.of(context).cardColor.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Assumptions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAssumptionItem(
                context,
                AppLocalizations.of(context)!.growth,
                '10%',
              ),
              _buildAssumptionItem(
                context,
                AppLocalizations.of(context)!.terminal,
                '3%',
              ),
              _buildAssumptionItem(
                context,
                AppLocalizations.of(context)!.discount,
                '9%',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.intrinsicValue,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.simpleCurrency().format(245.50),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.currentPrice + ': ',
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 13,
                  ),
                ),
                Text(
                  NumberFormat.simpleCurrency().format(185.92),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssumptionItem(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
