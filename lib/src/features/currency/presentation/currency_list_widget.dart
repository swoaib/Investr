import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../domain/currency_conversion.dart';

class CurrencyListWidget extends StatelessWidget {
  final List<CurrencyConversion> conversions;
  final VoidCallback onAddCurrency;
  final Function(CurrencyConversion) onRemove;
  final DateTime? lastUpdated;
  final bool isLoading;

  const CurrencyListWidget({
    required this.conversions,
    required this.onAddCurrency,
    required this.onRemove,
    this.lastUpdated,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmerLoading(context);
    }

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
        Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 160,
                ),
                itemCount: conversions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final conversion = conversions[index];
                  return _CurrencyListItem(
                    conversion: conversion,
                    onRemove: () => onRemove(conversion),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 100, // Floating above bottom nav
          child: GestureDetector(
            onTap: onAddCurrency,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: (Theme.of(context).cardTheme.color ?? Colors.white)
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey.shade600
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Pair',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.grey.shade600
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 160,
        ),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}

class _CurrencyListItem extends StatelessWidget {
  final CurrencyConversion conversion;
  final VoidCallback onRemove;

  const _CurrencyListItem({required this.conversion, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate result
    final calculatedValue = conversion.amount * conversion.rate;

    return Dismissible(
      key: ValueKey(conversion.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
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
            if (conversion.viaUSD) ...[
              const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
              const Spacer(),
              const _FlagIcon(code: 'us'),
              const Spacer(),
              const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
            ] else
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
      ),
    );
  }
}

class _FlagIcon extends StatelessWidget {
  final String code;

  const _FlagIcon({required this.code});

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.asset(
          'assets/flags/$code.svg',
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            color: Colors.grey,
            alignment: Alignment.center,
            child: Text(
              code.toUpperCase(),
              style: const TextStyle(fontSize: size * 0.25),
            ),
          ),
        ),
      ),
    );
  }
}
