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
      padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSentimentOption(
                  context,
                  assetPath: 'assets/images/feedback/smiley_sad.png',
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
                  assetPath: 'assets/images/feedback/smiley_neutral.png',
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
                  assetPath: 'assets/images/feedback/smiley_happy.png',
                  onTap: () async {
                    Navigator.pop(context);
                    final InAppReview inAppReview = InAppReview.instance;

                    if (await inAppReview.isAvailable()) {
                      await inAppReview.requestReview();
                    } else {
                      // fallback to open store listing?
                      // await inAppReview.openStoreListing();
                      // For now, let's just stick to the request if available.
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
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(assetPath, width: 64, height: 64),
    );
  }
}
