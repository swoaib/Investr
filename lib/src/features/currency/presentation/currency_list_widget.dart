import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../domain/currency_conversion.dart';

class CurrencyListWidget extends StatelessWidget {
  final List<CurrencyConversion> conversions;
  final VoidCallback onAddCurrency;

  const CurrencyListWidget({
    required this.conversions,
    required this.onAddCurrency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (conversions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No currencies added yet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAddCurrency,
              child: const Text('Add Currency'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: conversions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final conversion = conversions[index];
        return _CurrencyListItem(conversion: conversion);
      },
    );
  }
}

class _CurrencyListItem extends StatelessWidget {
  final CurrencyConversion conversion;

  const _CurrencyListItem({required this.conversion});

  @override
  Widget build(BuildContext context) {
    // Determine flag capability (simple check for now)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Format: "1 USD = 10.99 NOK"
    // Left: Target Currency (NOK) + Flag
    // Right: Equivalent in Base (USD) + Flag?
    // Or just "10.99 NOK" on right, and "1 USD" on left?
    // User requested "nok on one side and the usd value on the other side".
    // Let's do:
    // Left: Target (NOK) Flag + Code
    // Right: Rate + Base Code (USD)

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          // Target Side (e.g. NOK)
          _FlagIcon(code: conversion.targetFlag),
          const SizedBox(width: 12),
          Text(
            conversion.targetCurrency,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          // Exchange Rate Side (e.g. 0.091 USD)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${conversion.rate}', // TODO: Format properly
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                conversion.baseCurrency,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 8),
          _FlagIcon(code: conversion.baseFlag),
        ],
      ),
    );
  }
}

class _FlagIcon extends StatelessWidget {
  final String code;

  const _FlagIcon({required this.code});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
        child: SvgPicture.asset(
          'assets/flags/$code.svg',
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            color: Colors.grey,
            alignment: Alignment.center,
            child: Text(
              code.toUpperCase(),
              style: const TextStyle(fontSize: 8),
            ),
          ),
        ),
      ),
    );
  }
}
