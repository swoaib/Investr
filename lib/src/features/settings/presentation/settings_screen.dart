import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../../shared/locale/locale_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.themeMode),
          _RadioListTile<ThemeMode>(
            title: l10n.system,
            value: ThemeMode.system,
            groupValue: themeController.themeMode,
            onChanged: (value) => themeController.updateThemeMode(value!),
          ),
          _RadioListTile<ThemeMode>(
            title: l10n.light,
            value: ThemeMode.light,
            groupValue: themeController.themeMode,
            onChanged: (value) => themeController.updateThemeMode(value!),
          ),
          _RadioListTile<ThemeMode>(
            title: l10n.dark,
            value: ThemeMode.dark,
            groupValue: themeController.themeMode,
            onChanged: (value) => themeController.updateThemeMode(value!),
          ),
          const Divider(),
          _SectionHeader(title: l10n.language),
          _RadioListTile<Locale?>(
            title: l10n.system,
            value: null,
            groupValue: localeController.locale,
            onChanged: (value) => localeController.updateLocale(value),
          ),
          _RadioListTile<Locale?>(
            title: 'English',
            value: const Locale('en'),
            groupValue: localeController.locale,
            onChanged: (value) => localeController.updateLocale(value),
          ),
          _RadioListTile<Locale?>(
            title: 'Norsk',
            value: const Locale('no'),
            groupValue: localeController.locale,
            onChanged: (value) => localeController.updateLocale(value),
          ),
          _RadioListTile<Locale?>(
            title: '日本語',
            value: const Locale('ja'),
            groupValue: localeController.locale,
            onChanged: (value) => localeController.updateLocale(value),
          ),
          const Divider(),
          _SectionHeader(title: l10n.notifications),
          SwitchListTile(
            title: Text(l10n.enableNotifications),
            value: true,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            title: Text(l10n.newsUpdates),
            value: true,
            onChanged: (value) {},
          ),
          CheckboxListTile(
            title: Text(l10n.marketAlerts),
            value: false,
            onChanged: (value) {},
          ),
          const Divider(),
          _SectionHeader(title: l10n.about),
          ListTile(title: Text(l10n.version), subtitle: const Text('1.0.0')),
          ListTile(title: Text(l10n.termsOfService), onTap: () {}),
          ListTile(title: Text(l10n.privacyPolicy), onTap: () {}),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGreen),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.upgradeToPro,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.upgradeToProDesc, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l10n.upgradeNow),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RadioListTile<T> extends StatelessWidget {
  final String title;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const _RadioListTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
