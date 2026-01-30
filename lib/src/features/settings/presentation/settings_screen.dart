import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investr/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../shared/currency/currency_controller.dart';
import '../../../shared/locale/locale_controller.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation_bar.dart';
import '../../../shared/widgets/info_container.dart';
import 'alerts_management_screen.dart';
import 'appearance_screen.dart';
import 'widgets/feedback_bottom_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localeController = context.watch<LocaleController>();
    final currencyController = context.watch<CurrencyController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom:
                CustomBottomNavigationBar.contentBottomPadding +
                MediaQuery.of(context).padding.bottom,
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
                title: l10n.appearance,
                icon: Icons.palette_outlined, // appearance icon
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppearanceScreen(),
                    ),
                  );
                },
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
                title: l10n.currencyTitle,
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

  String _getLocaleText(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.system;
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'nb':
        return 'Norsk';
      case 'ja':
        return '日本語';
      default:
        return l10n.system;
    }
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
              RadioGroup<Locale?>(
                groupValue: controller.locale,
                onChanged: (value) {
                  controller.updateLocale(value);
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    _buildLanguageOption(
                      context,
                      title: l10n.system,
                      locale: null,
                    ),
                    _buildLanguageOption(
                      context,
                      title: 'English',
                      locale: const Locale('en'),
                    ),
                    _buildLanguageOption(
                      context,
                      title: 'Norsk',
                      locale: const Locale('nb'),
                    ),
                    _buildLanguageOption(
                      context,
                      title: '日本語',
                      locale: const Locale('ja'),
                    ),
                  ],
                ),
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
  }) {
    return RadioListTile<Locale?>(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16)),
      value: locale,
      activeColor: AppTheme.primaryGreen,
    );
  }

  void _showCurrencySelection(
    BuildContext context,
    CurrencyController controller,
  ) {
    // List of major currencies
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AUD', 'CAD', 'NOK'];
    final l10n = AppLocalizations.of(context)!;

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
              maxHeight:
                  MediaQuery.of(context).size.height * 0.75, // Increased height
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        l10n.defaultCurrency,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InfoContainer(text: l10n.currencyDisclaimer),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: RadioGroup<String>(
                      groupValue: controller.currency,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setCurrency(value);
                          Navigator.pop(context);
                        }
                      },
                      child: Column(
                        children: currencies
                            .map(
                              (code) =>
                                  _buildCurrencyOption(context, code: code),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyOption(BuildContext context, {required String code}) {
    return RadioListTile<String>(
      title: Text(code, style: GoogleFonts.outfit(fontSize: 16)),
      value: code,
      activeColor: AppTheme.primaryGreen,
    );
  }
}
