import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/academy_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/competition_provider.dart';
import 'providers/market_provider.dart';
import 'providers/price_alert_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trading_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();

  // Initialize Real Firebase Service (Auth & Firestore)
  await FirebaseService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AuthProvider(storageService)),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => TradingProvider(storageService)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(storageService)),
        ChangeNotifierProvider(create: (_) => PriceAlertProvider(storageService)),
        ChangeNotifierProvider(create: (_) => CompetitionProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AcademyProvider(storageService)),
      ],
      child: const QuantSimTradingApp(),
    ),
  );
}

class QuantSimTradingApp extends StatefulWidget {
  const QuantSimTradingApp({super.key});

  @override
  State<QuantSimTradingApp> createState() => _QuantSimTradingAppState();
}

class _QuantSimTradingAppState extends State<QuantSimTradingApp> {
  @override
  void initState() {
    super.initState();
    // Connect Market Ticker and Auth callbacks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final marketProvider = context.read<MarketProvider>();
      final tradingProvider = context.read<TradingProvider>();
      final alertProvider = context.read<PriceAlertProvider>();
      final compProvider = context.read<CompetitionProvider>();
      final watchlistProvider = context.read<WatchlistProvider>();

      // When user logs in / registers / logs out, reload isolated database
      authProvider.onUserChanged = () {
        tradingProvider.reloadUserData();
        watchlistProvider.reloadUserData();
      };

      marketProvider.onTickUpdated = (stocks) {
        tradingProvider.processMarketTick(stocks);
        alertProvider.checkPriceAlerts(stocks);

        final totalPortfolioVal = tradingProvider.getTotalPortfolioValue(stocks);
        final returnsPercent = tradingProvider.getTotalReturnsPercent(stocks);
        compProvider.updateCurrentUserPerformance(totalPortfolioVal, returnsPercent);
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
