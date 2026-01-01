import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/alerts_repository.dart';
import '../domain/stock_alert.dart';
import '../../../shared/theme/app_theme.dart';

class SetAlertDialog extends StatefulWidget {
  final String symbol;
  final double currentPrice;

  const SetAlertDialog({
    super.key,
    required this.symbol,
    required this.currentPrice,
  });

  @override
  State<SetAlertDialog> createState() => _SetAlertDialogState();
}

class _SetAlertDialogState extends State<SetAlertDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String _condition = 'above'; // 'above' or 'below'

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentPrice.toStringAsFixed(2);
    // Determine default based on logic, but user can change it
  }

  Future<void> _saveAlert() async {
    final price = double.tryParse(_controller.text);
    if (price == null) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not signed in');
      }

      final repo = context.read<AlertsRepository>();
      final currentCount = await repo.getAlertCount(userId);

      if (currentCount >= 3) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You can only create 3 alerts.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final alert = StockAlert(
        id: const Uuid().v4(),
        symbol: widget.symbol,
        targetPrice: price,
        condition: _condition,
        isActive: true,
        userId: userId,
        createdAt: DateTime.now(),
      );

      if (!mounted) return;
      await context.read<AlertsRepository>().createAlert(alert);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alert set for ${widget.symbol} when price is $_condition \$${price.toStringAsFixed(2)}',
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        'Set Alert for ${widget.symbol}',
        style: theme.textTheme.titleLarge,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Notify me when price goes:', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'above',
                label: Text('Above'),
                icon: Icon(Icons.trending_up),
              ),
              ButtonSegment<String>(
                value: 'below',
                label: Text('Below'),
                icon: Icon(Icons.trending_down),
              ),
            ],
            selected: <String>{_condition},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _condition = newSelection.first;
              });
            },
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 24),
          Text('Target Price:', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.headlineSmall,
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: '0.00',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveAlert,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create Alert'),
        ),
      ],
    );
  }
}
