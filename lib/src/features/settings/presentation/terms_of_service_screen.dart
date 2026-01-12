import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import 'package:investr/l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate a default date or use a hardcoded one if preferred.
    // For now, using a static date.
    final lastUpdated = 'December 29, 2025';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.termsOfService),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: $lastUpdated',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Investr. By using our app, you agree to these Terms of Service. Please read them carefully.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '1. Educational Purpose Only',
              content:
                  'Investr is strictly an educational tool designed to help users understand stock market concepts using simulated data or historical data for demonstration purposes. We do not offer real money trading, brokerage services, or financial advice.',
            ),
            _buildSection(
              context,
              title: '2. No Financial Advice',
              content:
                  'The content provided within Investr, including stock data, news, and educational materials, is for informational purposes only. It should not be construed as financial, investment, or legal advice. You should consult with a qualified professional before making any financial decisions.',
            ),
            _buildSection(
              context,
              title: '3. Data Accuracy',
              content:
                  'While we strive to provide accurate and up-to-date information via third-party providers (like Polygon.io), we cannot guarantee the accuracy, completeness, or timeliness of any data. Market data may be delayed.',
            ),
            _buildSection(
              context,
              title: '4. Limitation of Liability',
              content:
                  'In no event shall Investr or its developers be liable for any direct, indirect, incidental, special, or consequential damages arising out of or in any way connected with the use of this app or the information contained herein.',
            ),
            _buildSection(
              context,
              title: '5. Intellectual Property',
              content:
                  'All content included in the app, such as text, graphics, logos, and software, is the property of Investr or its content suppliers and protected by international copyright laws.',
            ),
            _buildSection(
              context,
              title: '6. Changes to Terms',
              content:
                  'We reserve the right to modify these terms at any time. Your continued use of the app following any changes indicates your acceptance of the new terms.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
