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

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 160, // Ensure last item is not hidden behind button
          ),
          itemCount: conversions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final conversion = conversions[index];
            return _CurrencyListItem(conversion: conversion);
          },
        ),
        Positioned(
          right: 16,
          bottom: 100, // Floating above bottom nav
          child: OutlinedButton.icon(
            onPressed: onAddCurrency,
            icon: const Icon(Icons.add),
            label: const Text('Add Pair'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyListItem extends StatelessWidget {
  final CurrencyConversion conversion;

  const _CurrencyListItem({required this.conversion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate result
    final calculatedValue = conversion.amount * conversion.rate;

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
          // Base Side (From)
          _FlagIcon(code: conversion.baseFlag),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversion.baseCurrency,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                conversion.amount.toStringAsFixed(2),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          const Spacer(),
          // Target Side (To)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calculatedValue.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                conversion.targetCurrency,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 12),
          _FlagIcon(code: conversion.targetFlag),
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
