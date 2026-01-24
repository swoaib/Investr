import 'package:flutter/material.dart';

class SlidingSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;

  const SlidingSegmentedControl({
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = children.length;
        if (count < 2) return const SizedBox();

        // 1. Calculate desired width per item based on text
        final textStyle =
            Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ) ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

        double maxItemWidth = 0;
        for (final text in children.values) {
          final textPainter = TextPainter(
            text: TextSpan(text: text, style: textStyle),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          if (textPainter.width > maxItemWidth) {
            maxItemWidth = textPainter.width;
          }
        }

        // Add padding to item width (horizontal padding inside the item)
        // 16px padding on each side seems appropriate for a pill shape
        final itemWidthWithPadding = maxItemWidth + 32.0;

        // 2. Determine container width
        // If constraints are tight/finite, use them.
        // If unbounded (Infinity), use calculated size.
        double totalWidth;
        if (constraints.maxWidth.isFinite) {
          totalWidth = constraints.maxWidth;
        } else {
          totalWidth = itemWidthWithPadding * count;
        }

        // Recalculate itemWidth to exactly fit the determined totalWidth
        final itemWidth = totalWidth / count;

        // Determine index
        final keys = children.keys.toList();
        final index = keys.indexOf(groupValue);
        final alignX = index == -1 ? -1.0 : -1.0 + (index / (count - 1)) * 2.0;

        return Container(
          width: totalWidth,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              // Sliding Pill Background
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment(alignX, 0.0),
                child: Container(
                  width: itemWidth,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.brightnessOf(context) == Brightness.dark
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              // Touch Targets & Labels
              Row(
                children: children.entries.map((entry) {
                  final isSelected = entry.key == groupValue;
                  return SizedBox(
                    width: itemWidth,
                    height: 32,
                    child: GestureDetector(
                      onTap: () => onValueChanged(entry.key),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: textStyle.copyWith(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.7),
                          ),
                          child: Text(entry.value),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
