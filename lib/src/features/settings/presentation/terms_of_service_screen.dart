import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.termsOfService,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: December 29, 2025',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Please read these Terms of Service ("Terms", "Terms of Service") carefully before using the Investr mobile application (the "App") operated by Investr ("us", "we", or "our").\n\nYour access to and use of the App is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users, and others who access or use the App.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '1. Educational Purpose Only',
              content:
                  'The content provided within the App, including but not limited to educational modules, stock data, valuation tools, and "Investr" calculations, is for informational and educational purposes only. It is NOT intended as financial, investment, tax, or legal advice.',
            ),
            _buildSection(
              context,
              title: '2. No Financial Advice',
              content:
                  'Investr is not a financial advisor, broker, or dealer. We do not recommend or suggest any specific securities, currencies, or financial instruments. You understand that all investments involve risk, including the loss of principal. You alone are responsible for your investment decisions.',
            ),
            _buildSection(
              context,
              title: '3. Data Accuracy and Third-Party Services',
              content:
                  'We use third-party services (such as Polygon.io) to provide market data. While we strive for accuracy, we cannot guarantee the timeliness, accuracy, or completeness of any data. Market data may be delayed. We are not liable for any errors or delays in content, or for any actions taken in reliance on any content.',
            ),
            _buildSection(
              context,
              title: '4. Limitation of Liability',
              content:
                  'In no event shall Investr, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the App; (ii) any conduct or content of any third party on the App; (iii) any content obtained from the App; and (iv) unauthorized access, use, or alteration of your transmissions or content.',
            ),
            _buildSection(
              context,
              title: '5. Intellectual Property',
              content:
                  'The App and its original content (excluding content provided by you or other users), features, and functionality are and will remain the exclusive property of Investr and its licensors. The App is protected by copyright, trademark, and other laws.',
            ),
            _buildSection(
              context,
              title: '6. Changes',
              content:
                  'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will try to provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.',
            ),
            _buildSection(
              context,
              title: 'Contact Us',
              content:
                  'If you have any questions about these Terms, please contact us.\n\nEmail: scalier.foe-7h@icloud.com',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
      ],
    );
  }
}
