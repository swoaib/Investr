import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class PopularBrokersWidget extends StatefulWidget {
  const PopularBrokersWidget({super.key});

  @override
  State<PopularBrokersWidget> createState() => _PopularBrokersWidgetState();
}

class _PopularBrokersWidgetState extends State<PopularBrokersWidget> {
  String _selectedCountry = 'NO';

  final Map<String, List<Map<String, String>>> _brokers = {
    'US': [
      {'name': 'Fidelity', 'type': 'Full Service'},
      {'name': 'Charles Schwab', 'type': 'Full Service'},
      {'name': 'Robinhood', 'type': 'Mobile First'},
      {'name': 'Vanguard', 'type': 'Long Term'},
      {'name': 'Interactive Brokers', 'type': 'Pro'},
    ],
    'UK': [
      {'name': 'Trading 212', 'type': 'FCA Regulated'},
      {'name': 'Freetrade', 'type': 'Mobile First'},
      {'name': 'Hargreaves Lansdown', 'type': 'Established'},
      {'name': 'Interactive Investor', 'type': 'Flat Fee'},
    ],
    'CA': [
      {'name': 'Wealthsimple', 'type': 'Commission Free'},
      {'name': 'Questrade', 'type': 'Low Fee'},
      {'name': 'TD Direct Investing', 'type': 'Bank Owned'},
      {'name': 'Interactive Brokers', 'type': 'Pro'},
    ],
    'AU': [
      {'name': 'CommSec', 'type': 'Bank Owned'},
      {'name': 'Stake', 'type': 'US Stocks'},
      {'name': 'Pearler', 'type': 'Long Term'},
      {'name': 'SelfWealth', 'type': 'Flat Fee'},
    ],
    'IN': [
      {'name': 'Zerodha', 'type': 'Discount Broker'},
      {'name': 'Groww', 'type': 'Mobile First'},
      {'name': 'Upstox', 'type': 'Discount Broker'},
      {'name': 'Angel One', 'type': 'Full Service'},
    ],
    'DE': [
      {'name': 'Trade Republic', 'type': 'Neo Broker'},
      {'name': 'Scalable Capital', 'type': 'Neo Broker'},
      {'name': 'Comdirect', 'type': 'Bank Owned'},
    ],
    'NO': [
      {'name': 'Nordnet', 'type': 'Leading Nordic'},
      {'name': 'DNB Markets', 'type': 'Bank Owned'},
      {'name': 'Saxo Bank', 'type': 'Pro Platform'},
      {'name': 'Interactive Brokers', 'type': 'Global Access'},
    ],
    'JP': [
      {'name': 'SBI Securities', 'type': 'Market Leader'},
      {'name': 'Rakuten Securities', 'type': 'E-Commerce Giant'},
      {'name': 'Monex', 'type': 'Global Access'},
      {'name': 'Nomura', 'type': 'Full Service'},
      {'name': 'Matsui', 'type': 'Long Established'},
    ],
    'FR': [
      {'name': 'BoursoBank', 'type': 'Bank Leader'},
      {'name': 'Fortuneo', 'type': 'Low Fee'},
      {'name': 'Trade Republic', 'type': 'Neo Broker'},
      {'name': 'Saxo Bank', 'type': 'Pro Platform'},
      {'name': 'Interactive Brokers', 'type': 'Global Access'},
    ],
    'CH': [
      {'name': 'Swissquote', 'type': 'Market Leader'},
      {'name': 'Saxo Bank', 'type': 'Pro Platform'},
      {'name': 'Interactive Brokers', 'type': 'Global Access'},
      {'name': 'DEGIRO', 'type': 'Low Fee'},
      {'name': 'Cornèrtrader', 'type': 'Bank Owned'},
    ],
  };

  final Map<String, String> _countryNames = {
    'US': 'United States 🇺🇸',
    'UK': 'United Kingdom 🇬🇧',
    'CA': 'Canada 🇨🇦',
    'AU': 'Australia 🇦🇺',
    'IN': 'India 🇮🇳',
    'DE': 'Germany 🇩🇪',
    'NO': 'Norway 🇳🇴',
    'JP': 'Japan 🇯🇵',
    'FR': 'France 🇫🇷',
    'CH': 'Switzerland 🇨🇭',
  };

  @override
  Widget build(BuildContext context) {
    final brokers = _brokers[_selectedCountry] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _countryNames.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCountry = value;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: brokers.map((broker) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              broker['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              broker['type']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
