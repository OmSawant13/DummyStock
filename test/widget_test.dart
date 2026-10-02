import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stock_trading/main.dart';
import 'package:smart_stock_trading/providers/academy_provider.dart';
import 'package:smart_stock_trading/providers/auth_provider.dart';
import 'package:smart_stock_trading/providers/competition_provider.dart';
import 'package:smart_stock_trading/providers/market_provider.dart';
import 'package:smart_stock_trading/providers/price_alert_provider.dart';
import 'package:smart_stock_trading/providers/theme_provider.dart';
import 'package:smart_stock_trading/providers/trading_provider.dart';
import 'package:smart_stock_trading/providers/watchlist_provider.dart';
import 'package:smart_stock_trading/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test initializes and displays Market tab', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(
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

    await tester.pumpAndSettle();
    expect(find.text('QuantSim Market'), findsOneWidget);
  });
}
