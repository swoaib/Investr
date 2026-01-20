import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StockLogo extends StatelessWidget {
  final String url;
  final String symbol;
  final String? countryCode;
  final String? exchange;
  final String? currency;
  final double size;

  const StockLogo({
    super.key,
    required this.url,
    required this.symbol,
    this.countryCode,
    this.exchange,
    this.currency,
    this.size = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: size,
        height: size,
        color: (symbol == 'NIO' || symbol == 'AMZN')
            ? Colors.grey.shade900
            : symbol == 'SONY'
            ? Colors.white
            : isDark
            ? Colors.grey.shade900
            : Colors.white,
        padding:
            (symbol == 'AAPL' ||
                symbol.startsWith('^') ||
                symbol.contains('FOREX'))
            ? EdgeInsets.zero
            : const EdgeInsets.all(4.0),
        child: (symbol.startsWith('^') || symbol.contains('FOREX'))
            ? _buildFallback(isDark)
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback(isDark);
                },
              ),
      ),
    );
  }

  Widget _buildFallback(bool isDark) {
    // If it's a known index or has a known country code, show a flag.
    // Otherwise show the first letter.
    final code = countryCode?.toLowerCase() ?? _inferCountryCode();

    // Check if we have this asset locally (using the same set as before)
    const knownAssets = {
      'ad',
      'ae',
      'af',
      'ag',
      'ai',
      'al',
      'am',
      'ao',
      'aq',
      'ar',
      'as',
      'at',
      'au',
      'aw',
      'ax',
      'az',
      'ba',
      'bb',
      'bd',
      'be',
      'bf',
      'bg',
      'bh',
      'bi',
      'bj',
      'bl',
      'bm',
      'bn',
      'bo',
      'bq',
      'br',
      'bs',
      'bt',
      'bv',
      'bw',
      'by',
      'bz',
      'ca',
      'cc',
      'cd',
      'cf',
      'cg',
      'ch',
      'ci',
      'ck',
      'cl',
      'cm',
      'cn',
      'co',
      'cr',
      'cu',
      'cv',
      'cw',
      'cx',
      'cy',
      'cz',
      'de',
      'dg',
      'dj',
      'dk',
      'dm',
      'do',
      'dz',
      'ea',
      'ec',
      'ee',
      'eg',
      'eh',
      'er',
      'es-ct',
      'es-ga',
      'es',
      'et',
      'eu',
      'fi',
      'fj',
      'fk',
      'fm',
      'fo',
      'fr',
      'ga',
      'gb-eng',
      'gb-nir',
      'gb-sct',
      'gb-wls',
      'gb',
      'gd',
      'ge',
      'gf',
      'gg',
      'gh',
      'gi',
      'gl',
      'gm',
      'gn',
      'gp',
      'gq',
      'gr',
      'gs',
      'gt',
      'gu',
      'gw',
      'gy',
      'hk',
      'hm',
      'hn',
      'hr',
      'ht',
      'hu',
      'ic',
      'id',
      'ie',
      'il',
      'im',
      'in',
      'io',
      'iq',
      'ir',
      'is',
      'it',
      'je',
      'jm',
      'jo',
      'jp',
      'ke',
      'kg',
      'kh',
      'ki',
      'km',
      'kn',
      'kp',
      'kr',
      'kw',
      'ky',
      'kz',
      'la',
      'lb',
      'lc',
      'li',
      'lk',
      'lr',
      'ls',
      'lt',
      'lu',
      'lv',
      'ly',
      'ma',
      'mc',
      'md',
      'me',
      'mf',
      'mg',
      'mh',
      'mk',
      'ml',
      'mm',
      'mn',
      'mo',
      'mp',
      'mq',
      'mr',
      'ms',
      'mt',
      'mu',
      'mv',
      'mw',
      'mx',
      'my',
      'mz',
      'na',
      'nc',
      'ne',
      'nf',
      'ng',
      'ni',
      'nl',
      'no',
      'np',
      'nr',
      'nu',
      'nz',
      'om',
      'pa',
      'pe',
      'pf',
      'pg',
      'ph',
      'pk',
      'pl',
      'pm',
      'pn',
      'pr',
      'ps',
      'pt',
      'pw',
      'py',
      'qa',
      're',
      'ro',
      'rs',
      'ru',
      'rw',
      'sa',
      'sb',
      'sc',
      'sd',
      'se',
      'sg',
      'sh',
      'si',
      'sj',
      'sk',
      'sl',
      'sm',
      'sn',
      'so',
      'sr',
      'ss',
      'st',
      'sv',
      'sx',
      'sy',
      'sz',
      'ta',
      'tc',
      'td',
      'tf',
      'tg',
      'th',
      'tj',
      'tk',
      'tl',
      'tm',
      'tn',
      'to',
      'tr',
      'tt',
      'tv',
      'tw',
      'tz',
      'ua',
      'ug',
      'um',
      'un',
      'us',
      'uy',
      'uz',
      'va',
      'vc',
      've',
      'vg',
      'vi',
      'vn',
      'vu',
      'wf',
      'ws',
      'xk',
      'xx',
      'ye',
      'yt',
      'za',
      'zm',
      'zw',
    };
    final useLocal = knownAssets.contains(code);

    return Container(
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
      alignment: Alignment.center,
      child: useLocal
          ? SvgPicture.asset(
              'assets/flags/$code.svg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.network(
              'https://flagcdn.com/w80/$code.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  symbol.isNotEmpty ? symbol[0] : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                );
              },
            ),
    );
  }

  String _inferCountryCode() {
    // 0. Explicit Index Overrides
    if (symbol == '^N225') return 'jp'; // Nikkei 225
    if (symbol == '^HSI') return 'hk'; // Hang Seng
    if (symbol == '^FTSE') return 'gb'; // FTSE 100
    if (symbol == '^GDAXI') return 'de'; // DAX
    if (symbol == '^FCHI') return 'fr'; // CAC 40
    if (symbol == '^KS11') return 'kr'; // KOSPI
    if (symbol == '^BSESN') return 'in'; // BSE Sensex
    if (symbol == '^STI') return 'sg'; // Straits Times

    // 1. Check Exchange
    if (exchange != null) {
      final ex = exchange!.toUpperCase();
      if (ex.contains('LONDON') || ex == 'LSE' || ex == 'FTSE') return 'gb';
      if (ex.contains('TORONTO') || ex == 'TSX') return 'ca';
      if (ex.contains('PARIS') || ex == 'EURONEXT') {
        return 'fr'; // Catch-all for Euronext often France
      }
      if (ex.contains('FRANKFURT') || ex.contains('XETRA') || ex == 'GER') {
        return 'de';
      }
      if (ex.contains('HONG KONG') || ex == 'HKSE') return 'hk';
      if (ex.contains('INDIA') || ex == 'NSE' || ex == 'BSE') return 'in';
      if (ex.contains('AUSTRALIAN') || ex == 'ASX') return 'au';
      if (ex.contains('SAO PAULO') || ex == 'BOVESPA') return 'br';
      if (ex.contains('TOKYO') || ex == 'JPX') return 'jp';
      if (ex.contains('KOREA') || ex == 'KSE') return 'kr';
      if (ex.contains('SIX')) return 'ch';
    }

    // 2. Check Currency
    if (currency != null) {
      final cur = currency!.toUpperCase();
      switch (cur) {
        case 'GBP':
          return 'gb';
        case 'CAD':
          return 'ca';
        case 'JPY':
          return 'jp';
        case 'AUD':
          return 'au';
        case 'INR':
          return 'in';
        case 'HKD':
          return 'hk';
        case 'BRL':
          return 'br';
        case 'CHF':
          return 'ch';
        case 'CNY':
          return 'cn';
        case 'SGD':
          return 'sg';
        case 'EUR':
          return 'eu'; // Generic EU flag for Euro
      }
    }

    // 3. Handle Suffixes (Exchange) - Fallback
    if (symbol.contains('.')) {
      final suffix = symbol.split('.').last;
      switch (suffix) {
        case 'L':
          return 'gb';
        case 'TO':
          return 'ca';
        case 'PA':
          return 'fr';
        case 'DE':
          return 'de';
        case 'HK':
          return 'hk';
        case 'KS':
          return 'kr';
        case 'SI':
          return 'sg';
        case 'MI':
          return 'it';
        case 'MC':
          return 'es';
        case 'AS':
          return 'nl';
        case 'BR':
          return 'be';
        case 'SW':
          return 'ch'; // Swiss
        case 'SA':
          return 'br'; // Sao Paulo
        case 'V':
          return 'ca'; // TSX Venture
        case 'NE':
          return 'ca'; // NEO
      }
    }

    // 4. Forex/Crypto heuristics
    if (!symbol.contains('.')) {
      if (symbol.startsWith('EUR')) return 'eu';
      if (symbol.startsWith('GBP')) return 'gb';
      if (symbol.startsWith('JPY')) return 'jp';
      if (symbol.startsWith('CAD')) return 'ca';
      if (symbol.startsWith('AUD')) return 'au';
      if (symbol.startsWith('CNY')) return 'cn';
    }

    // 5. Default to US
    return 'us';
  }
}
