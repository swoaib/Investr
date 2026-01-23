import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import '../../alerts/data/alerts_repository.dart';
import '../../alerts/domain/stock_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../shared/theme/theme_controller.dart';
import 'package:investr/l10n/app_localizations.dart';
import '../../../shared/widgets/info_container.dart';
import '../../../shared/widgets/stock_logo.dart';
import '../../alerts/presentation/alert_dialog.dart';

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
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.loginToManageAlerts),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.manageAlertsTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InfoContainer(text: l10n.alertLimitMessage),
          ),
          Expanded(
            child: StreamBuilder<List<StockAlert>>(
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
                          size: 48,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noActiveAlerts,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 0, bottom: 16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Slidable(
                      key: Key(alert.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (ctx) {
                              _editAlert(context, alert);
                            },
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: l10n.edit,
                          ),
                          SlidableAction(
                            onPressed: (ctx) {
                              _deleteAlert(context, alert);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: l10n.delete,
                          ),
                        ],
                      ),
                      child: ListTile(
                        dense: true,
                        leading: StockLogo(
                          url:
                              'https://images.financialmodelingprep.com/symbol/${alert.symbol}.png',
                          symbol: alert.symbol,
                        ),
                        title: Text(
                          alert.symbol,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          alert.condition == "above"
                              ? l10n.targetAbove(
                                  alert.targetPrice.toStringAsFixed(2),
                                )
                              : l10n.targetBelow(
                                  alert.targetPrice.toStringAsFixed(2),
                                ),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Switch(
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAlert(BuildContext context, StockAlert alert) async {
    try {
      await context.read<AlertsRepository>().deleteAlert(alert.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.alertDeleted),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error(e.toString())),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error(e.toString())),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppTheme.screenPaddingHorizontal),
          ),
        );
      }
    }
  }

  void _editAlert(BuildContext context, StockAlert alert) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SetAlertDialog(
          symbol: alert.symbol,
          currentPrice: alert.targetPrice, // Ignored when existingAlert is set
          existingAlert: alert,
        );
      },
    );
  }
}
