import 'package:flutter/material.dart';
import 'package:investr/l10n/app_localizations.dart';

import '../../../shared/widgets/markdown_viewer_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MarkdownViewerScreen(
      title: AppLocalizations.of(context)!.privacyPolicy,
      assetPath: 'assets/privacy_policy.md',
    );
  }
}
