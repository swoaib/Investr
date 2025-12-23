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

  /// No description provided for @inflationTitle.
  ///
  /// In en, this message translates to:
  /// **'Inflation'**
  String get inflationTitle;

  /// No description provided for @inflationDesc.
  ///
  /// In en, this message translates to:
  /// **'The silent thief of your money.'**
  String get inflationDesc;

  /// No description provided for @inflationBalloonTitle.
  ///
  /// In en, this message translates to:
  /// **'The Balloon Effect'**
  String get inflationBalloonTitle;

  /// No description provided for @inflationBalloonDesc.
  ///
  /// In en, this message translates to:
  /// **'Inflation is when prices rise over time. Like a balloon inflating, it takes more money to buy the same things.'**
  String get inflationBalloonDesc;

  /// No description provided for @purchasingPowerTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchasing Power'**
  String get purchasingPowerTitle;

  /// No description provided for @purchasingPowerDesc.
  ///
  /// In en, this message translates to:
  /// **'Your money buys less over time. \$100 today might only buy \$70 worth of goods in 10 years.'**
  String get purchasingPowerDesc;

  /// No description provided for @cpiBasketTitle.
  ///
  /// In en, this message translates to:
  /// **'The CPI Basket'**
  String get cpiBasketTitle;

  /// No description provided for @cpiBasketDesc.
  ///
  /// In en, this message translates to:
  /// **'Economists measure inflation by tracking the price of a \'basket\' of goods like food, housing, and fuel.'**
  String get cpiBasketDesc;

  /// No description provided for @inflationShieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Beating Inflation'**
  String get inflationShieldTitle;

  /// No description provided for @inflationShieldDesc.
  ///
  /// In en, this message translates to:
  /// **'Investing is your shield. To grow your wealth, your returns must be higher than the inflation rate.'**
  String get inflationShieldDesc;

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
  /// **'Calculating Intrinsic Value (Advanced)'**
  String get calcIntrinsicValueTitle;

  /// No description provided for @calcIntrinsicValueDesc.
  ///
  /// In en, this message translates to:
  /// **'The science of valuation.'**
  String get calcIntrinsicValueDesc;

  /// No description provided for @powerOfCompoundingTitle.
  ///
  /// In en, this message translates to:
  /// **'The Power of Compounding'**
  String get powerOfCompoundingTitle;

  /// No description provided for @powerOfCompoundingDesc.
  ///
  /// In en, this message translates to:
  /// **'Why starting early matters.'**
  String get powerOfCompoundingDesc;

  /// No description provided for @snowballEffect.
  ///
  /// In en, this message translates to:
  /// **'Snowball Effect'**
  String get snowballEffect;

  /// No description provided for @snowballEffectDesc.
  ///
  /// In en, this message translates to:
  /// **'Compounding is like a snowball rolling down a hill. As it grows, it gathers more snow, growing faster and faster.'**
  String get snowballEffectDesc;

  /// No description provided for @timeIsKey.
  ///
  /// In en, this message translates to:
  /// **'Time is Key'**
  String get timeIsKey;

  /// No description provided for @timeIsKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'The longer you stay invested, the more your money works for you. Starting 10 years earlier can double your result.'**
  String get timeIsKeyDesc;

  /// No description provided for @exponentialGrowth.
  ///
  /// In en, this message translates to:
  /// **'Exponential Growth'**
  String get exponentialGrowth;

  /// No description provided for @exponentialGrowthDesc.
  ///
  /// In en, this message translates to:
  /// **'Simple interest is linear. Compound interest is exponential. Your interest earns interest, creating a curve of wealth.'**
  String get exponentialGrowthDesc;

  /// No description provided for @dollarCostAveragingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dollar Cost Averaging'**
  String get dollarCostAveragingTitle;

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

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to get started.'**
  String get chooseLanguageDesc;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @chooseThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a look that fits your style. You can change this later in settings.'**
  String get chooseThemeDesc;

  /// No description provided for @trackYourStocks.
  ///
  /// In en, this message translates to:
  /// **'Track Your Stocks'**
  String get trackYourStocks;

  /// No description provided for @trackYourStocksDesc.
  ///
  /// In en, this message translates to:
  /// **'Get real-time updates on your favorite stocks and market trends.'**
  String get trackYourStocksDesc;

  /// No description provided for @learnToInvest.
  ///
  /// In en, this message translates to:
  /// **'Learn to Invest'**
  String get learnToInvest;

  /// No description provided for @learnToInvestDesc.
  ///
  /// In en, this message translates to:
  /// **'Master the basics of investing with our curated educational content.'**
  String get learnToInvestDesc;

  /// No description provided for @valueYourPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Value Your Portfolio'**
  String get valueYourPortfolio;

  /// No description provided for @valueYourPortfolioDesc.
  ///
  /// In en, this message translates to:
  /// **'Use advanced tools to calculate intrinsic value and make informed decisions.'**
  String get valueYourPortfolioDesc;

  /// No description provided for @howToInvestTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Invest'**
  String get howToInvestTitle;

  /// No description provided for @howToInvestDesc.
  ///
  /// In en, this message translates to:
  /// **'Brokers, ETFs, and getting started.'**
  String get howToInvestDesc;

  /// No description provided for @theBroker.
  ///
  /// In en, this message translates to:
  /// **'The Broker'**
  String get theBroker;

  /// No description provided for @theBrokerDesc.
  ///
  /// In en, this message translates to:
  /// **'Your broker is your gateway to the market. Today, this is typically a mobile app or a bank. They execute your buy and sell orders.'**
  String get theBrokerDesc;

  /// No description provided for @accountTypes.
  ///
  /// In en, this message translates to:
  /// **'Account Types'**
  String get accountTypes;

  /// No description provided for @accountTypesDesc.
  ///
  /// In en, this message translates to:
  /// **'Look for tax-advantaged accounts (like ISAs, Roth IRAs, or ASK). Using these can save you thousands in taxes over the long run.'**
  String get accountTypesDesc;

  /// No description provided for @etfs.
  ///
  /// In en, this message translates to:
  /// **'ETFs'**
  String get etfs;

  /// No description provided for @etfsDesc.
  ///
  /// In en, this message translates to:
  /// **'Exchange Traded Funds (ETFs) are baskets of stocks that trade like a single stock. They are modern, low-cost, and diverse.'**
  String get etfsDesc;

  /// No description provided for @mutualFunds.
  ///
  /// In en, this message translates to:
  /// **'Mutual Funds'**
  String get mutualFunds;

  /// No description provided for @mutualFundsDesc.
  ///
  /// In en, this message translates to:
  /// **'Similar to ETFs but often actively managed by a professional. Beware: they typically have higher fees which eat into your returns.'**
  String get mutualFundsDesc;

  /// No description provided for @ethicalInvesting.
  ///
  /// In en, this message translates to:
  /// **'Ethical Investing (ESG)'**
  String get ethicalInvesting;

  /// No description provided for @ethicalInvestingDesc.
  ///
  /// In en, this message translates to:
  /// **'You can vote with your wallet. ESG funds only include companies that meet Environmental, Social, and Governance standards.'**
  String get ethicalInvestingDesc;

  /// No description provided for @moduleFoundation.
  ///
  /// In en, this message translates to:
  /// **'The Foundation'**
  String get moduleFoundation;

  /// No description provided for @moduleAssetClasses.
  ///
  /// In en, this message translates to:
  /// **'Asset Classes'**
  String get moduleAssetClasses;

  /// No description provided for @modulePhilosophy.
  ///
  /// In en, this message translates to:
  /// **'The Philosophy'**
  String get modulePhilosophy;

  /// No description provided for @moduleStrategy.
  ///
  /// In en, this message translates to:
  /// **'Practical Strategy'**
  String get moduleStrategy;

  /// No description provided for @understandingMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding Metrics'**
  String get understandingMetricsTitle;

  /// No description provided for @understandingMetricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn to speak the language.'**
  String get understandingMetricsDesc;

  /// No description provided for @marketCapTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get marketCapTitle;

  /// No description provided for @marketCapDesc.
  ///
  /// In en, this message translates to:
  /// **'Market Capitalization is the total value of a company. It\'s calculated by multiplying the stock price by the number of shares.'**
  String get marketCapDesc;

  /// No description provided for @peRatioTitle.
  ///
  /// In en, this message translates to:
  /// **'P/E Ratio'**
  String get peRatioTitle;

  /// No description provided for @peRatioImgDesc.
  ///
  /// In en, this message translates to:
  /// **'The Price-to-Earnings ratio tells you how much you are paying for \$1 of earnings. A lower P/E *can* mean a bargain.'**
  String get peRatioImgDesc;

  /// No description provided for @dividendYieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Dividend Yield'**
  String get dividendYieldTitle;

  /// No description provided for @dividendYieldDesc.
  ///
  /// In en, this message translates to:
  /// **'This is the percentage of the stock price that is paid out to you in cash each year. It\'s like getting paid rent for owning the stock.'**
  String get dividendYieldDesc;

  /// No description provided for @epsTitle.
  ///
  /// In en, this message translates to:
  /// **'EPS (Earnings Per Share)'**
  String get epsTitle;

  /// No description provided for @epsDesc.
  ///
  /// In en, this message translates to:
  /// **'The portion of a company\'s profit allocated to each share. It is the engine that drives the stock price in the long run.'**
  String get epsDesc;

  /// No description provided for @defensiveVsEnterpriseTitle.
  ///
  /// In en, this message translates to:
  /// **'Defensive vs Enterprise'**
  String get defensiveVsEnterpriseTitle;

  /// No description provided for @defensiveVsEnterpriseDesc.
  ///
  /// In en, this message translates to:
  /// **'Passive vs Active Investing.'**
  String get defensiveVsEnterpriseDesc;

  /// No description provided for @twoPaths.
  ///
  /// In en, this message translates to:
  /// **'Two Paths'**
  String get twoPaths;

  /// No description provided for @twoPathsDesc.
  ///
  /// In en, this message translates to:
  /// **'Benjamin Graham defined two distinct types of investors based on the amount of effort they are willing to put in.'**
  String get twoPathsDesc;

  /// No description provided for @theDefensiveInvestor.
  ///
  /// In en, this message translates to:
  /// **'The Defensive Investor'**
  String get theDefensiveInvestor;

  /// No description provided for @theDefensiveInvestorDesc.
  ///
  /// In en, this message translates to:
  /// **'Prioritizes safety and freedom from bother. Their goal is to get decent returns with minimal effort and worry.'**
  String get theDefensiveInvestorDesc;

  /// No description provided for @defensiveStrategy.
  ///
  /// In en, this message translates to:
  /// **'Defensive Strategy'**
  String get defensiveStrategy;

  /// No description provided for @defensiveStrategyDesc.
  ///
  /// In en, this message translates to:
  /// **'They should buy a high-grade index fund or maintain a 50/50 split between stocks and bonds, rebalancing automatically.'**
  String get defensiveStrategyDesc;

  /// No description provided for @theEnterpriseInvestor.
  ///
  /// In en, this message translates to:
  /// **'The Enterprise Investor'**
  String get theEnterpriseInvestor;

  /// No description provided for @theEnterpriseInvestorDesc.
  ///
  /// In en, this message translates to:
  /// **'Willing to devote time and care to researching securities. They treat investing as a business or full-time job.'**
  String get theEnterpriseInvestorDesc;

  /// No description provided for @enterpriseStrategy.
  ///
  /// In en, this message translates to:
  /// **'Enterprise Strategy'**
  String get enterpriseStrategy;

  /// No description provided for @enterpriseStrategyDesc.
  ///
  /// In en, this message translates to:
  /// **'They analyze financial reports to find undervalued companies, seeking higher returns in exchange for their hard work.'**
  String get enterpriseStrategyDesc;

  /// No description provided for @stocksVsBondsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stocks vs. Bonds'**
  String get stocksVsBondsTitle;

  /// No description provided for @stocksVsBondsDesc.
  ///
  /// In en, this message translates to:
  /// **'Understanding Asset Classes.'**
  String get stocksVsBondsDesc;

  /// No description provided for @stocksForGrowth.
  ///
  /// In en, this message translates to:
  /// **'Stocks for Growth'**
  String get stocksForGrowth;

  /// No description provided for @stocksForGrowthDesc.
  ///
  /// In en, this message translates to:
  /// **'Stocks represent ownership. They offer high potential for growth but come with higher volatility and risk.'**
  String get stocksForGrowthDesc;

  /// No description provided for @bondsForStability.
  ///
  /// In en, this message translates to:
  /// **'Bonds for Stability'**
  String get bondsForStability;

  /// No description provided for @bondsForStabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Bonds are loans you make to governments or companies. They pay steady interest and are generally safer than stocks.'**
  String get bondsForStabilityDesc;

  /// No description provided for @riskVsReward.
  ///
  /// In en, this message translates to:
  /// **'Risk vs. Reward'**
  String get riskVsReward;

  /// No description provided for @riskVsRewardDesc.
  ///
  /// In en, this message translates to:
  /// **'It\'s a trade-off. Stocks can grow fast but crash hard. Bonds likely won\'t double, but they won\'t crash either.'**
  String get riskVsRewardDesc;

  /// No description provided for @theIdealMix.
  ///
  /// In en, this message translates to:
  /// **'The Ideal Mix'**
  String get theIdealMix;

  /// No description provided for @theIdealMixDesc.
  ///
  /// In en, this message translates to:
  /// **'Most investors hold both. Stocks drive the growth of your portfolio, while bonds act as shock absorbers during market crashes.'**
  String get theIdealMixDesc;

  /// No description provided for @theChoice.
  ///
  /// In en, this message translates to:
  /// **'The Choice'**
  String get theChoice;

  /// No description provided for @theChoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'The choice isn\'t just about risk appetite, but your willingness to work. If you can\'t put in the hours, be defensive.'**
  String get theChoiceDesc;

  /// No description provided for @freeCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Free Cash Flow'**
  String get freeCashFlow;

  /// No description provided for @terminalGrowthRate.
  ///
  /// In en, this message translates to:
  /// **'Terminal Growth Rate (%)'**
  String get terminalGrowthRate;

  /// No description provided for @netDebt.
  ///
  /// In en, this message translates to:
  /// **'Net Debt'**
  String get netDebt;

  /// No description provided for @sharesOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Shares Outstanding'**
  String get sharesOutstanding;

  /// No description provided for @selectStock.
  ///
  /// In en, this message translates to:
  /// **'Select Stock'**
  String get selectStock;

  /// No description provided for @enterSymbol.
  ///
  /// In en, this message translates to:
  /// **'Enter Symbol'**
  String get enterSymbol;

  /// No description provided for @assumptions.
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get assumptions;

  /// No description provided for @terminalRate.
  ///
  /// In en, this message translates to:
  /// **'Terminal Rate'**
  String get terminalRate;

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get currentPrice;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @dcfExplanation.
  ///
  /// In en, this message translates to:
  /// **'This calculator estimates the intrinsic value using the Discounted Cash Flow (DCF) model. It projects future cash flows based on your growth assumptions, discounts them back to today\'s value, adds a terminal value, and adjusts for the company\'s net debt.'**
  String get dcfExplanation;
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
