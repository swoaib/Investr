import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:investr/l10n/app_localizations.dart';

import 'feedback_bottom_sheet.dart';

class FeedbackSentimentBottomSheet extends StatelessWidget {
  const FeedbackSentimentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.feedbackSentimentTitle,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSentimentOption(
                  context,
                  icon: Icons.sentiment_dissatisfied_rounded,
                  color: const Color(0xFFE57373), // Red 300
                  label: l10n.feedbackSentimentSad,
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => FeedbackBottomSheet(
                        title: l10n.feedbackImprovementTitle,
                      ),
                    );
                  },
                ),
                _buildSentimentOption(
                  context,
                  icon: Icons.sentiment_neutral_rounded,
                  color: const Color(0xFFFFB74D), // Orange 300
                  label: l10n.feedbackSentimentNeutral,
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => FeedbackBottomSheet(
                        title: l10n.feedbackImprovementTitle,
                      ),
                    );
                  },
                ),
                _buildSentimentOption(
                  context,
                  icon: Icons.sentiment_very_satisfied_rounded,
                  color: const Color(0xFF81C784), // Green 300
                  label: l10n.feedbackSentimentHappy,
                  onTap: () async {
                    Navigator.pop(context);
                    final InAppReview inAppReview = InAppReview.instance;

                    if (await inAppReview.isAvailable()) {
                      await inAppReview.requestReview();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 48, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
