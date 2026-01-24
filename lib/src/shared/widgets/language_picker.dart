import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class LanguagePicker extends StatelessWidget {
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;

  const LanguagePicker({
    required this.selectedLocale, required this.onLocaleChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      _LanguageOption(l10n.system, null),
      _LanguageOption('English', const Locale('en')),
      _LanguageOption('Norsk', const Locale('no')),
      _LanguageOption('日本語', const Locale('ja')),
    ];

    final selectedIndex = options.indexWhere(
      (option) => option.locale?.languageCode == selectedLocale?.languageCode,
    );

    // Default to 0 (System) if not found, or maintain current selection logic
    final initialIndex = selectedIndex != -1 ? selectedIndex : 0;

    return SizedBox(
      height: 200,
      child: CupertinoPicker(
        itemExtent: 48,
        scrollController: FixedExtentScrollController(
          initialItem: initialIndex,
        ),
        onSelectedItemChanged: (index) {
          onLocaleChanged(options[index].locale);
        },
        children: options.map((option) {
          return Center(
            child: Text(
              option.label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight:
                    option.locale?.languageCode == selectedLocale?.languageCode
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LanguageOption {
  final String label;
  final Locale? locale;

  _LanguageOption(this.label, this.locale);
}
