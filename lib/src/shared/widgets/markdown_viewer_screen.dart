import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class MarkdownViewerScreen extends StatelessWidget {
  final String? title;
  final String assetPath;

  const MarkdownViewerScreen({required this.assetPath, this.title, super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the correct asset path based on locale if not already handled by caller.
    // However, to keep this generic, let's assume the caller passes the base path
    // and we handle localization here, or the caller handles full localization.
    // Better pattern: Caller handles logic or we have a helper.
    // Given the previous pattern in PrivacyPolicyScreen, let's make this smart enough
    // to handle localization if the base asset path is provided, OR we just do what
    // PrivacyPolicyScreen did but make it reusable.

    // Let's stick to the existing pattern:
    // We will pass the 'base' filename (e.g., 'privacy_policy.md') and handle the locale suffix here.

    final locale = Localizations.localeOf(context);
    String effectivePath = assetPath;

    // Check if we need to append locale. This assumes standard naming convention: name_code.md
    // We only do this if the specific localized file exists, but we can't easily check file existence
    // synchronously in build without AssetManifest.
    // For now, let's replicate the logic we had, which supports nb/no and ja.

    // Split extension
    if (assetPath.endsWith('.md')) {
      String basePath = assetPath.substring(0, assetPath.length - 3);
      if (locale.languageCode == 'nb' || locale.languageCode == 'no') {
        effectivePath = '${basePath}_nb.md';
      } else if (locale.languageCode == 'ja') {
        effectivePath = '${basePath}_ja.md';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: title != null
            ? Text(title!, style: Theme.of(context).textTheme.headlineSmall)
            : null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(effectivePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // Fallback to default (english) if localized fails
              if (effectivePath != assetPath) {
                return FutureBuilder<String>(
                  future: rootBundle.loadString(assetPath),
                  builder: (context, retrySnapshot) {
                    if (retrySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (retrySnapshot.hasError) {
                      return Center(child: Text('Error loading document'));
                    }
                    return _buildMarkdown(context, retrySnapshot.data ?? '');
                  },
                );
              }
              return Center(child: Text('Error loading document'));
            }
            return _buildMarkdown(context, snapshot.data ?? '');
          },
        ),
      ),
    );
  }

  Widget _buildMarkdown(BuildContext context, String data) {
    return Markdown(
      data: data,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: Theme.of(context).textTheme.bodyMedium,
        h1: Theme.of(context).textTheme.headlineLarge,
        h2: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          height: 2.0,
        ),
        h3: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
        listBullet: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
