import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../../shared/locale/locale_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.screenPaddingHorizontal,
                  AppTheme.screenPaddingVertical,
                  AppTheme.screenPaddingHorizontal,
                  AppTheme.screenPaddingVertical,
                ),
                child: Text(
                  l10n.settingsTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 16),
              // Upgrade Banner
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.screenPaddingHorizontal,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppTheme.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.upgradeToPro,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            l10n.upgradeToProDesc,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.upgradeNow),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Settings List
              _buildSettingsTile(
                context,
                title: l10n
                    .about, // Reused 'about' as placeholder for Account since Account wasn't localized
                onTap: () {},
              ), // Using 'About' or 'Account' - old code had Account. I don't have Account string. Using About for now or keep hardcoded if needed? The user wants design. I'll stick to 'Account' hardcoded as placeholder or remove it? The l10n file doesn't have Account. I'll omit it or use a placeholder. I'll skip Account to be safe on l10n.
              _buildSwitchTile(
                context,
                title: l10n.enableNotifications,
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              _buildSettingsTile(
                context,
                title: l10n.themeMode,
                onTap: () =>
                    _showThemeSelection(context, themeController, l10n),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getThemeText(themeController.themeMode, l10n),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              _buildSettingsTile(
                context,
                title: l10n.language,
                onTap: () =>
                    _showLanguageSelection(context, localeController, l10n),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getLocaleText(localeController.locale, l10n),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              // Added Policy links that were in the intermediate version
              _buildSettingsTile(
                context,
                title: l10n.termsOfService,
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                title: l10n.privacyPolicy,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.screenPaddingHorizontal,
        vertical: 8,
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.screenPaddingHorizontal,
        vertical: 8,
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppTheme.primaryGreen,
      activeThumbColor: Colors.white,
    );
  }

  String _getThemeText(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.system;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
    }
  }

  String _getLocaleText(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.system;
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'no':
        return 'Norsk';
      case 'ja':
        return '日本語';
      default:
        return l10n.system;
    }
  }

  void _showThemeSelection(
    BuildContext context,
    ThemeController controller,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.themeMode,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildThemeOption(
                context,
                title: l10n.system,
                mode: ThemeMode.system,
                currentMode: controller.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    controller.updateThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              _buildThemeOption(
                context,
                title: l10n.light,
                mode: ThemeMode.light,
                currentMode: controller.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    controller.updateThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              _buildThemeOption(
                context,
                title: l10n.dark,
                mode: ThemeMode.dark,
                currentMode: controller.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    controller.updateThemeMode(value);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16)),
      value: mode,
      groupValue: currentMode,
      activeColor: AppTheme.primaryGreen,
      onChanged: onChanged,
    );
  }

  void _showLanguageSelection(
    BuildContext context,
    LocaleController controller,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.language,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildLanguageOption(
                context,
                title: l10n.system,
                locale: null,
                currentLocale: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: 'English',
                locale: const Locale('en'),
                currentLocale: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: 'Norsk',
                locale: const Locale('no'),
                currentLocale: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: '日本語',
                locale: const Locale('ja'),
                currentLocale: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required Locale? locale,
    required Locale? currentLocale,
    required ValueChanged<Locale?> onChanged,
  }) {
    return RadioListTile<Locale?>(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16)),
      value: locale,
      groupValue: currentLocale,
      activeColor: AppTheme.primaryGreen,
      onChanged: onChanged,
    );
  }
}
