import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared/widgets/investr_button.dart';
import '../domain/currency_conversion.dart';

class CurrencyAddSheet extends StatefulWidget {
  const CurrencyAddSheet({super.key});

  @override
  State<CurrencyAddSheet> createState() => _CurrencyAddSheetState();
}

class _CurrencyAddSheetState extends State<CurrencyAddSheet> {
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
    'PKR',
    'SAR',
  ];

  String _baseCurrency = 'USD';
  String _targetCurrency = 'NOK';
  final TextEditingController _amountController = TextEditingController(
    text: '1',
  );

  static String _getFlag(String currencyCode) {
    if (currencyCode == 'EUR') return 'eu';
    if (currencyCode == 'GBP') return 'gb';
    return currencyCode.substring(0, 2).toLowerCase();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Currency Pair',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyDropdown(
                    _baseCurrency,
                    (val) => setState(() => _baseCurrency = val!),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  child: _buildCurrencyDropdown(
                    _targetCurrency,
                    (val) => setState(() => _targetCurrency = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: InvestrButton(
                text: 'Add Pair',
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 1.0;
                  final conversion = CurrencyConversion.create(
                    baseCurrency: _baseCurrency,
                    targetCurrency: _targetCurrency,
                    rate: 0, // Rate will be fetched by parent
                    amount: amount,
                  );
                  Navigator.pop(context, conversion);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: _supportedCurrencies.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(
                        'assets/flags/${_getFlag(code)}.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(code),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
