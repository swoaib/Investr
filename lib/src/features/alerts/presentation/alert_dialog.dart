import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:investr/l10n/app_localizations.dart';
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
    // Initial guess
    // If not changed, defaults to above.
  }

  void _updateCondition() {
    final price = double.tryParse(_controller.text);
    if (price != null) {
      setState(() {
        _condition = price > widget.currentPrice ? 'above' : 'below';
      });
    }
  }

  Future<void> _saveAlert() async {
    final price = double.tryParse(_controller.text);
    if (price == null) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('user_device_id');
      if (userId == null) {
        userId = const Uuid().v4();
        await prefs.setString('user_device_id', userId);
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
              'Alert set for ${widget.symbol} at \$${price.toStringAsFixed(2)}',
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
    return AlertDialog(
      title: Text('Set Alert for ${widget.symbol}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Notify me when price goes $_condition:'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => _updateCondition(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAlert,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
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
              : const Text('Set Alert'),
        ),
      ],
    );
  }
}
