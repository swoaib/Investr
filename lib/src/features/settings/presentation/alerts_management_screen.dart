import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import '../../alerts/data/alerts_repository.dart';
import '../../alerts/domain/stock_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../shared/theme/theme_controller.dart';

class AlertsManagementScreen extends StatelessWidget {
  const AlertsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final themeController = context.watch<ThemeController>();
    final isDark =
        themeController.themeMode == ThemeMode.dark ||
        (themeController.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to manage alerts')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Alerts',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<StockAlert>>(
        stream: context.read<AlertsRepository>().getUserAlerts(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active alerts',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Slidable(
                key: Key(alert.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (ctx) {
                        _deleteAlert(context, alert);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12),
                      ),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        alert.symbol.substring(0, 1),
                        style: GoogleFonts.outfit(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      alert.symbol,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Target: ${alert.condition == "above" ? "Above" : "Below"} \$${alert.targetPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                    trailing: Switch.adaptive(
                      value: alert.isActive,
                      activeTrackColor: AppTheme.primaryGreen,
                      onChanged: (val) {
                        _toggleActive(context, alert, val);
                      },
                    ),
                    onTap: () {
                      _editAlert(context, alert);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteAlert(BuildContext context, StockAlert alert) async {
    try {
      await context.read<AlertsRepository>().deleteAlert(alert.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Alert deleted')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _toggleActive(
    BuildContext context,
    StockAlert alert,
    bool isActive,
  ) async {
    try {
      // Create new alert with updated status
      final updatedAlert = StockAlert(
        id: alert.id,
        symbol: alert.symbol,
        targetPrice: alert.targetPrice,
        condition: alert.condition,
        isActive: isActive,
        userId: alert.userId,
        createdAt: alert.createdAt,
      );
      await context.read<AlertsRepository>().updateAlert(updatedAlert);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _editAlert(BuildContext context, StockAlert alert) {
    final TextEditingController priceController = TextEditingController(
      text: alert.targetPrice.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Alert for ${alert.symbol}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Target Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newPrice = double.tryParse(priceController.text);
                if (newPrice != null) {
                  final updatedAlert = StockAlert(
                    id: alert.id,
                    symbol: alert.symbol,
                    targetPrice: newPrice,
                    condition: alert.condition,
                    isActive: alert.isActive,
                    userId: alert.userId,
                    createdAt: alert.createdAt,
                  );
                  await context.read<AlertsRepository>().updateAlert(
                    updatedAlert,
                  );
                  if (context.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
