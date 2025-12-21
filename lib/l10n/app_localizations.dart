import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_no.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('no'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @newsUpdates.
  ///
  /// In en, this message translates to:
  /// **'News updates'**
  String get newsUpdates;

  /// No description provided for @marketAlerts.
  ///
  /// In en, this message translates to:
  /// **'Market alerts'**
  String get marketAlerts;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @upgradeToProDesc.
  ///
  /// In en, this message translates to:
  /// **'Get advanced analysis and real-time data'**
  String get upgradeToProDesc;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @stocks101Title.
  ///
  /// In en, this message translates to:
  /// **'Stocks 101'**
  String get stocks101Title;

  /// No description provided for @stocks101Desc.
  ///
  /// In en, this message translates to:
  /// **'Start your journey here.'**
  String get stocks101Desc;

  /// No description provided for @whatIsAStock.
  ///
  /// In en, this message translates to:
  /// **'What is a Stock?'**
  String get whatIsAStock;

  /// No description provided for @whatIsAStockDesc.
  ///
  /// In en, this message translates to:
  /// **'A stock represents fractional ownership in a company. When you buy a share, you become a part-owner of that business.'**
  String get whatIsAStockDesc;

  /// No description provided for @theStockMarket.
  ///
  /// In en, this message translates to:
  /// **'The Stock Market'**
  String get theStockMarket;

  /// No description provided for @theStockMarketDesc.
  ///
  /// In en, this message translates to:
  /// **'The stock market is where buyers and sellers meet to trade shares. Think of it as a supermarket for companies.'**
  String get theStockMarketDesc;

  /// No description provided for @whyInvest.
  ///
  /// In en, this message translates to:
  /// **'Why Invest?'**
  String get whyInvest;

  /// No description provided for @whyInvestDesc.
  ///
  /// In en, this message translates to:
  /// **'Investing allows your money to grow over time, helping you beat inflation and build long-term wealth.'**
  String get whyInvestDesc;

  /// No description provided for @investingVsSpeculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Investment vs. Speculation'**
  String get investingVsSpeculationTitle;

  /// No description provided for @investingVsSpeculationDesc.
  ///
  /// In en, this message translates to:
  /// **'Understand the difference.'**
  String get investingVsSpeculationDesc;

  /// No description provided for @whatIsAnInvestment.
  ///
  /// In en, this message translates to:
  /// **'What is an Investment?'**
  String get whatIsAnInvestment;

  /// No description provided for @whatIsAnInvestmentDesc.
  ///
  /// In en, this message translates to:
  /// **'An operation that, upon thorough analysis, promises safety of principal and an adequate return.'**
  String get whatIsAnInvestmentDesc;

  /// No description provided for @theSpeculator.
  ///
  /// In en, this message translates to:
  /// **'The Speculator'**
  String get theSpeculator;

  /// No description provided for @theSpeculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Speculators bet on price movements without understanding the underlying business. It\'s essentially gambling.'**
  String get theSpeculatorDesc;

  /// No description provided for @beAnInvestor.
  ///
  /// In en, this message translates to:
  /// **'Be an Investor'**
  String get beAnInvestor;

  /// No description provided for @beAnInvestorDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on the long-term value of the business, not just the ticker price simply moving up and down.'**
  String get beAnInvestorDesc;

  /// No description provided for @mrMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'Mr. Market'**
  String get mrMarketTitle;

  /// No description provided for @mrMarketDesc.
  ///
  /// In en, this message translates to:
  /// **'The Intelligent Investor concept.'**
  String get mrMarketDesc;

  /// No description provided for @meetMrMarket.
  ///
  /// In en, this message translates to:
  /// **'Meet Mr. Market'**
  String get meetMrMarket;

  /// No description provided for @meetMrMarketDesc.
  ///
  /// In en, this message translates to:
  /// **'Imagine a business partner offering to buy your share or sell you his every day at a different price.'**
  String get meetMrMarketDesc;

  /// No description provided for @heIsEmotional.
  ///
  /// In en, this message translates to:
  /// **'He is Emotional'**
  String get heIsEmotional;

  /// No description provided for @heIsEmotionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Some days he is euphoric and sets a high price. Other days he is depressed and sets a low price.'**
  String get heIsEmotionalDesc;

  /// No description provided for @yourAdvantage.
  ///
  /// In en, this message translates to:
  /// **'Your Advantage'**
  String get yourAdvantage;

  /// No description provided for @yourAdvantageDesc.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to trade with him inside his mood swings. Use his emotional prices to your advantage.'**
  String get yourAdvantageDesc;

  /// No description provided for @intrinsicValue.
  ///
  /// In en, this message translates to:
  /// **'Intrinsic Value'**
  String get intrinsicValue;

  /// No description provided for @intrinsicValueDesc.
  ///
  /// In en, this message translates to:
  /// **'Focus on the intrinsic value of the business. Buy when the price is well below this value, and sell when it is well above.'**
  String get intrinsicValueDesc;

  /// No description provided for @disciplineIsKey.
  ///
  /// In en, this message translates to:
  /// **'Discipline is Key'**
  String get disciplineIsKey;

  /// No description provided for @disciplineIsKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'The investor without a disciplined approach will likely fall victim to Mr. Market\'s irrationality.'**
  String get disciplineIsKeyDesc;

  /// No description provided for @marginOfSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Margin of Safety'**
  String get marginOfSafetyTitle;

  /// No description provided for @marginOfSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'Risk management strategy.'**
  String get marginOfSafetyDesc;

  /// No description provided for @theSecret.
  ///
  /// In en, this message translates to:
  /// **'The Secret'**
  String get theSecret;

  /// No description provided for @theSecretDesc.
  ///
  /// In en, this message translates to:
  /// **'Benjamin Graham\'s secret to investing: Purchase assets for less than they are truly worth.'**
  String get theSecretDesc;

  /// No description provided for @roomForError.
  ///
  /// In en, this message translates to:
  /// **'Room for Error'**
  String get roomForError;

  /// No description provided for @roomForErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Buying at a discount protects you if your analysis is slightly off or if the future is unpredictable.'**
  String get roomForErrorDesc;

  /// No description provided for @theEngineersBridge.
  ///
  /// In en, this message translates to:
  /// **'The Engineer\'s Bridge'**
  String get theEngineersBridge;

  /// No description provided for @theEngineersBridgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Like a bridge built to hold 30,000 lbs but only carrying 10,000 lbs, your portfolio needs structural integrity.'**
  String get theEngineersBridgeDesc;

  /// No description provided for @diversification.
  ///
  /// In en, this message translates to:
  /// **'Diversification'**
  String get diversification;

  /// No description provided for @diversificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Margin of safety is also achieved by not putting all your eggs in one basket. Spreading risk protects your capital.'**
  String get diversificationDesc;

  /// No description provided for @conservativeAssumptions.
  ///
  /// In en, this message translates to:
  /// **'Conservative Assumptions'**
  String get conservativeAssumptions;

  /// No description provided for @conservativeAssumptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'When valuing a company, always use conservative estimates for growth and profitability to ensure a margin of safety.'**
  String get conservativeAssumptionsDesc;

  /// No description provided for @indexFundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Index Funds'**
  String get indexFundsTitle;

  /// No description provided for @indexFundsDesc.
  ///
  /// In en, this message translates to:
  /// **'The power of passive investing.'**
  String get indexFundsDesc;

  /// No description provided for @whatIsAnIndexFund.
  ///
  /// In en, this message translates to:
  /// **'What is an Index Fund?'**
  String get whatIsAnIndexFund;

  /// No description provided for @whatIsAnIndexFundDesc.
  ///
  /// In en, this message translates to:
  /// **'An index fund is a portfolio of stocks designed to mimic the composition and performance of a financial market index.'**
  String get whatIsAnIndexFundDesc;

  /// No description provided for @instantDiversification.
  ///
  /// In en, this message translates to:
  /// **'Instant Diversification'**
  String get instantDiversification;

  /// No description provided for @instantDiversificationDesc.
  ///
  /// In en, this message translates to:
  /// **'By buying an index fund, you instantly own a tiny piece of hundreds or thousands of companies, spreading your risk.'**
  String get instantDiversificationDesc;

  /// No description provided for @lowCost.
  ///
  /// In en, this message translates to:
  /// **'Low Cost'**
  String get lowCost;

  /// No description provided for @lowCostDesc.
  ///
  /// In en, this message translates to:
  /// **'Index funds are passively managed, meaning they have significantly lower fees compared to actively managed mutual funds.'**
  String get lowCostDesc;

  /// No description provided for @marketPerformance.
  ///
  /// In en, this message translates to:
  /// **'Market Performance'**
  String get marketPerformance;

  /// No description provided for @marketPerformanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Statistically, most actively managed funds fail to beat the market over the long term. If you can\'t beat them, join them.'**
  String get marketPerformanceDesc;

  /// No description provided for @calcIntrinsicValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculating Intrinsic Value'**
  String get calcIntrinsicValueTitle;

  /// No description provided for @calcIntrinsicValueDesc.
  ///
  /// In en, this message translates to:
  /// **'The science of valuation.'**
  String get calcIntrinsicValueDesc;

  /// No description provided for @priceVsValue.
  ///
  /// In en, this message translates to:
  /// **'Price vs. Value'**
  String get priceVsValue;

  /// No description provided for @priceVsValueDesc.
  ///
  /// In en, this message translates to:
  /// **'Price is what you pay. Value is what you get. A stock might cost \$100, but its intrinsic value could be \$50 or \$150.'**
  String get priceVsValueDesc;

  /// No description provided for @theFormulaDCF.
  ///
  /// In en, this message translates to:
  /// **'The Formula (DCF)'**
  String get theFormulaDCF;

  /// No description provided for @theFormulaDCFDesc.
  ///
  /// In en, this message translates to:
  /// **'Valuation often uses Discounted Cash Flow (DCF). It sums up all future cash a company will generate, discounted back to today.'**
  String get theFormulaDCFDesc;

  /// No description provided for @stepByStep.
  ///
  /// In en, this message translates to:
  /// **'Step-by-Step'**
  String get stepByStep;

  /// No description provided for @stepByStepDesc.
  ///
  /// In en, this message translates to:
  /// **'1. Estimate future Free Cash Flow growth.\n2. Choose a Discount Rate (your desired return).\n3. Sum the discounted values.'**
  String get stepByStepDesc;

  /// No description provided for @useOurCalculator.
  ///
  /// In en, this message translates to:
  /// **'Use Our Calculator'**
  String get useOurCalculator;

  /// No description provided for @useOurCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'This math can be complex. Use the \"Intrinsic Value Calculator\" tool in this app to do the heavy lifting for you.'**
  String get useOurCalculatorDesc;

  /// No description provided for @dollarCostAveragingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dollar Cost Averaging'**
  String get dollarCostAveragingTitle;

  /// No description provided for @dollarCostAveragingDesc.
  ///
  /// In en, this message translates to:
  /// **'Build wealth through consistency.'**
  String get dollarCostAveragingDesc;

  /// No description provided for @whatIsDCA.
  ///
  /// In en, this message translates to:
  /// **'What is DCA?'**
  String get whatIsDCA;

  /// No description provided for @whatIsDCADesc.
  ///
  /// In en, this message translates to:
  /// **'Investing a fixed amount of money at regular intervals, regardless of the share price.'**
  String get whatIsDCADesc;

  /// No description provided for @smoothingTheRide.
  ///
  /// In en, this message translates to:
  /// **'Smoothing the Ride'**
  String get smoothingTheRide;

  /// No description provided for @smoothingTheRideDesc.
  ///
  /// In en, this message translates to:
  /// **'You buy more shares when prices are low and fewer when prices are high, lowering your average cost per share.'**
  String get smoothingTheRideDesc;

  /// No description provided for @removeEmotion.
  ///
  /// In en, this message translates to:
  /// **'Remove Emotion'**
  String get removeEmotion;

  /// No description provided for @removeEmotionDesc.
  ///
  /// In en, this message translates to:
  /// **'It eliminates the temptation to time the market, preventing emotional decisions during volatility.'**
  String get removeEmotionDesc;

  /// No description provided for @consistencyWins.
  ///
  /// In en, this message translates to:
  /// **'Consistency Wins'**
  String get consistencyWins;

  /// No description provided for @consistencyWinsDesc.
  ///
  /// In en, this message translates to:
  /// **'The key is consistency. Over time, this disciplined approach builds significant wealth.'**
  String get consistencyWinsDesc;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @keyStatistics.
  ///
  /// In en, this message translates to:
  /// **'Key Statistics'**
  String get keyStatistics;

  /// No description provided for @marketCap.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get marketCap;

  /// No description provided for @peRatio.
  ///
  /// In en, this message translates to:
  /// **'P/E Ratio'**
  String get peRatio;

  /// No description provided for @divYield.
  ///
  /// In en, this message translates to:
  /// **'Div Yield'**
  String get divYield;

  /// No description provided for @eps.
  ///
  /// In en, this message translates to:
  /// **'EPS'**
  String get eps;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @earningsHistory.
  ///
  /// In en, this message translates to:
  /// **'Earnings History'**
  String get earningsHistory;

  /// No description provided for @revenueHistory.
  ///
  /// In en, this message translates to:
  /// **'Revenue History'**
  String get revenueHistory;

  /// No description provided for @earningsPerShare.
  ///
  /// In en, this message translates to:
  /// **'Earnings Per Share (EPS)'**
  String get earningsPerShare;

  /// No description provided for @revenueUSD.
  ///
  /// In en, this message translates to:
  /// **'Revenue (USD)'**
  String get revenueUSD;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @annual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// No description provided for @noEarningsHistory.
  ///
  /// In en, this message translates to:
  /// **'No earning history available'**
  String get noEarningsHistory;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @navStocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get navStocks;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get navValue;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @valuationDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Intrinsic Value'**
  String get valuationDisplayTitle;

  /// No description provided for @growthRate.
  ///
  /// In en, this message translates to:
  /// **'Growth Rate (%)'**
  String get growthRate;

  /// No description provided for @discountRate.
  ///
  /// In en, this message translates to:
  /// **'Discount Rate (%)'**
  String get discountRate;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @estimatedValue.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value:'**
  String get estimatedValue;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @stockMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Market'**
  String get stockMarketTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search (e.g. AAPL)'**
  String get searchHint;

  /// No description provided for @noStocksInWatchlist.
  ///
  /// In en, this message translates to:
  /// **'No stocks in watchlist'**
  String get noStocksInWatchlist;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @removedFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'removed from watchlist'**
  String get removedFromWatchlist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'no'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'no':
      return AppLocalizationsNo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
