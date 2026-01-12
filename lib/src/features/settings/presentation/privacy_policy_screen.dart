import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import 'package:investr/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacyPolicy),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: December 29, 2025',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              'This Privacy Policy describes how Investr (“we”, “us”, or “our”) collects, uses, and discloses your information when you use our mobile application (the “App”).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Information Collection and Use',
              content: '',
            ),
            _buildSubsection(
              context,
              title: 'Personal Data',
              content:
                  'We do not collect any personally identifiable information (PII) such as your name, email address, phone number, or location data. You do not need to create an account to use the App.',
            ),
            _buildSubsection(
              context,
              title: 'Usage Data',
              content:
                  'The App stores your preferences and data locally on your device using on-device storage (SharedPreferences). This includes:\n\n'
                  '• Watchlist: The list of stocks you have chosen to track.\n'
                  '• App Settings: Your preferences for theme (Light/Dark/System) and language.\n'
                  '• Onboarding Status: Whether you have completed the initial app introduction.\n'
                  '• Lesson Progress: Your progress through the educational modules.\n\n'
                  'This data remains on your device and is not transmitted to our servers (as we do not have any).',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Third-Party Services',
              content:
                  'We use third-party services to provide stock market data. These third parties may collect information used to identify your device, such as your IP address, to facilitate API requests.',
            ),
            _buildSubsection(
              context,
              title: 'Polygon.io',
              content:
                  'We use Polygon.io to fetch real-time and historical stock market data, company details, financials, and news. By using our App, you acknowledge that your device makes direct requests to the Polygon.io API. Please refer to Polygon.io’s Privacy Policy for more information on how they handle data.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Data Retention',
              content:
                  'Since we do not collect personal data on our servers, we do not retain your personal data. The data stored locally on your device is retained until you uninstall the App or clear the App’s data in your device settings.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Security',
              content:
                  'We value your trust in providing us your information. Since all user-generated data (watchlist, settings) is stored locally on your device, the security of that data relies on the security of your mobile device. We do not maintain any external databases of user information.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Children’s Privacy',
              content:
                  'Our App does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Changes to This Privacy Policy',
              content:
                  'We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Contact Us',
              content:
                  'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us.\n\n'
                  'Email: scalier.foe-7h@icloud.com',
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
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }

  Widget _buildSubsection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
