import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../../shared/locale/locale_controller.dart';
import '../../../shared/currency/currency_controller.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import 'alerts_management_screen.dart';
import 'widgets/feedback_bottom_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final localeController = context.watch<LocaleController>();
    final currencyController = context.watch<CurrencyController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: CustomBottomNavigationBar.contentBottomPadding,
          ),
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
              _buildSettingsTile(
                context,
                title: l10n.manageAlerts,
                icon: Icons.notifications_outlined, // manage alerts icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlertsManagementScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context,
                title: l10n.themeMode,
                icon: Icons.brightness_6_outlined, // theme mode icon
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
                icon: Icons.language_outlined, // language icon
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
              _buildSettingsTile(
                context,
                title: "Currency",
                icon: Icons.attach_money_rounded,
                onTap: () =>
                    _showCurrencySelection(context, currencyController),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyController.currency,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              _buildSettingsTile(
                context,
                title: l10n.feedbackTitle,
                icon: Icons.chat_bubble_outline, // feedback icon
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const FeedbackBottomSheet(),
                  );
                },
              ),
              _buildSettingsTile(
                context,
                title: l10n.privacyPolicy,
                icon: Icons.description_outlined, // privacy policy icon
                onTap: () {
                  context.push('/settings/privacy-policy');
                },
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
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.screenPaddingHorizontal,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                groupValue: controller.themeMode,
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
                groupValue: controller.themeMode,
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
                groupValue: controller.themeMode,
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
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16)),
      value: mode,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
    );
  }

  void _showLanguageSelection(
    BuildContext context,
    LocaleController controller,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                groupValue: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: 'English',
                locale: const Locale('en'),
                groupValue: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: 'Norsk',
                locale: const Locale('no'),
                groupValue: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
              ),
              _buildLanguageOption(
                context,
                title: '日本語',
                locale: const Locale('ja'),
                groupValue: controller.locale,
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
    required Locale? groupValue,
    required ValueChanged<Locale?> onChanged,
  }) {
    return RadioListTile<Locale?>(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16)),
      value: locale,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
    );
  }

  void _showCurrencySelection(
    BuildContext context,
    CurrencyController controller,
  ) {
    // List of major currencies
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AUD', 'CAD'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Default Currency",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...currencies.map(
                    (code) => _buildCurrencyOption(
                      context,
                      code: code,
                      groupValue: controller.currency,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setCurrency(value);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyOption(
    BuildContext context, {
    required String code,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(code, style: GoogleFonts.outfit(fontSize: 16)),
      value: code,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
    );
  }
}
