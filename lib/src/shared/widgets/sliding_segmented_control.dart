import 'package:flutter/material.dart';

class SlidingSegmentedControl<T> extends StatelessWidget {
  final Map<T, Widget> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;
  final Color? thumbColor;

  const SlidingSegmentedControl({
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.thumbColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = children.length;
        if (count < 2) return const SizedBox();

        // Determine container width
        // If constraints are tight/finite, use them.
        // If unbounded (Infinity), use a default width per item.
        double totalWidth;
        if (constraints.maxWidth.isFinite) {
          totalWidth = constraints.maxWidth;
        } else {
          // Default item width if unbounded (e.g. in a Row)
          // 100.0 is a reasonable default for text labels like "Overview"
          // It can be adjusted or made configurable if needed in the future
          totalWidth = 100.0 * count;
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
                    color:
                        thumbColor ??
                        (Theme.brightnessOf(context) == Brightness.dark
                            ? Colors.grey.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.3)),
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
                          style:
                              (Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ) ??
                                      const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ))
                                  .copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withValues(alpha: 0.7),
                                  ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                              size: 20,
                            ),
                            child: entry.value,
                          ),
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
