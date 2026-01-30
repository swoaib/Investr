import 'package:flutter/material.dart';

import '../../../shared/widgets/markdown_viewer_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MarkdownViewerScreen(
      assetPath: 'assets/privacy_policy.md',
    );
  }
}
