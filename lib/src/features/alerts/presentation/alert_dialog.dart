import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investr/l10n/app_localizations.dart';

import '../data/alerts_repository.dart';
import '../domain/stock_alert.dart';
import '../../../shared/theme/app_theme.dart';

class SetAlertDialog extends StatefulWidget {
  final String symbol;
  final double currentPrice;
  final StockAlert? existingAlert;

  const SetAlertDialog({
    super.key,
    required this.symbol,
    required this.currentPrice,
    this.existingAlert,
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
    if (widget.existingAlert != null) {
      _condition = widget.existingAlert!.condition;
      _controller.text = widget.existingAlert!.targetPrice.toStringAsFixed(2);
    } else {
      _controller.text = widget.currentPrice.toStringAsFixed(2);
    }
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
      final l10n = AppLocalizations.of(context)!;

      // Only check limit if creating a NEW alert
      if (widget.existingAlert == null) {
        final currentCount = await repo.getAlertCount(userId);
        if (currentCount >= 3) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.alertLimitReached),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
            ),
          );
          return;
        }
      }

      final alert = StockAlert(
        id: widget.existingAlert?.id ?? const Uuid().v4(),
        symbol: widget.symbol,
        targetPrice: price,
        condition: _condition,
        isActive: true,
        userId: userId,
        createdAt: widget.existingAlert?.createdAt ?? DateTime.now(),
      );

      if (!mounted) return;

      if (widget.existingAlert != null) {
        await repo.updateAlert(alert);
      } else {
        await repo.createAlert(alert);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAlert != null
                  ? l10n.alertUpdated(widget.symbol)
                  : l10n.alertSet(
                      widget.symbol,
                      _condition == 'above' ? l10n.above : l10n.below,
                      price.toStringAsFixed(2),
                    ),
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingAlert != null;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        isEditing
            ? l10n.editAlertTitle(widget.symbol)
            : l10n.setAlertTitle(widget.symbol),
        style: theme.textTheme.titleLarge,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.notifyWhenPrice, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment<String>(
                value: 'above',
                label: Text(l10n.above),
                icon: const Icon(Icons.trending_up),
              ),
              ButtonSegment<String>(
                value: 'below',
                label: Text(l10n.below),
                icon: const Icon(Icons.trending_down),
              ),
            ],
            selected: <String>{_condition},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _condition = newSelection.first;
              });
            },
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.targetPrice, style: theme.textTheme.bodyMedium),
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
          child: Text(l10n.cancel),
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
              : Text(
                  widget.existingAlert != null
                      ? l10n.saveChanges
                      : l10n.createAlert,
                ),
        ),
      ],
    );
  }
}
