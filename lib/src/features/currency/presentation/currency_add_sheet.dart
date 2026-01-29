import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrencyAddSheet extends StatelessWidget {
  const CurrencyAddSheet({super.key});

  static const List<String> _supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'NOK',
    'SEK',
    'DKK',
    'CAD',
    'AUD',
    'INR',
    'JPY',
    'CHF',
    'CNY',
  ];

  static String _getFlag(String currencyCode) {
    if (currencyCode == 'EUR') return 'eu';
    if (currencyCode == 'GBP') return 'gb';
    return currencyCode.substring(0, 2).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Add Currency',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _supportedCurrencies.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final code = _supportedCurrencies[index];
                return ListTile(
                  leading: ClipOval(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: SvgPicture.asset(
                        'assets/flags/${_getFlag(code)}.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(code),
                  onTap: () {
                    Navigator.pop(context, code);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
