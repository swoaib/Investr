import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LanguagePicker extends StatelessWidget {
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;

  const LanguagePicker({
    super.key,
    required this.selectedLocale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      _LanguageOption('English', const Locale('en'), '🇺🇸'),
      _LanguageOption('Norsk', const Locale('no'), '🇳🇴'),
      _LanguageOption('日本語', const Locale('ja'), '🇯🇵'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected =
            selectedLocale?.languageCode == option.locale.languageCode;
        return GestureDetector(
          onTap: () => onLocaleChanged(option.locale),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : Colors.grey.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(option.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryGreen : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LanguageOption {
  final String label;
  final Locale locale;
  final String flag;

  _LanguageOption(this.label, this.locale, this.flag);
}
