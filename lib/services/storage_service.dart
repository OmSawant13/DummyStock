import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/position_model.dart';
import '../models/transaction_model.dart';
import '../models/price_alert_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static const String _keyRegisteredUsers = 'quant_registered_users';
  static const String _keyUserCredentials = 'quant_user_credentials';
  static const String _keyCurrentUserId = 'quant_current_user_id';
  static const String _keyThemeMode = 'quant_theme_mode';
  static const String _keyRegisteredLeagues = 'quant_registered_leagues';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _seedDefaultUserIfEmpty();
  }

  void _seedDefaultUserIfEmpty() {
    final users = getAllUsers();
    if (users.isEmpty) {
      final defaultUser = UserModel(
        id: 'usr_student_1',
        name: 'Om Sawant',
        email: 'student@quanttrade.edu',
        college: 'Mumbai Institute of Technology',
        studentId: 'MIT-FIN-2026',
        role: 'Student Quant Trader',
        registeredAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      registerUser(defaultUser, 'password123');
      setCurrentUserId(defaultUser.id);
    }
  }

  // --- Auth Database Operations ---

  List<UserModel> getAllUsers() {
    final raw = _prefs.getString(_keyRegisteredUsers);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => UserModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> registerUser(UserModel user, String password) async {
    final users = getAllUsers();
    users.removeWhere((u) => u.email.toLowerCase() == user.email.toLowerCase());
    users.add(user);

    await _prefs.setString(_keyRegisteredUsers, jsonEncode(users.map((e) => e.toJson()).toList()));

    // Store credentials map
    final credsRaw = _prefs.getString(_keyUserCredentials);
    Map<String, dynamic> creds = credsRaw != null ? jsonDecode(credsRaw) : {};
    creds[user.email.toLowerCase()] = password;
    await _prefs.setString(_keyUserCredentials, jsonEncode(creds));
  }

  UserModel? authenticate(String email, String password) {
    final credsRaw = _prefs.getString(_keyUserCredentials);
    if (credsRaw == null) return null;
    final creds = jsonDecode(credsRaw) as Map<String, dynamic>;

    final storedPass = creds[email.toLowerCase()];
    if (storedPass == null || storedPass != password) return null;

    final users = getAllUsers();
    return users.where((u) => u.email.toLowerCase() == email.toLowerCase()).firstOrNull;
  }

  String? getCurrentUserId() {
    return _prefs.getString(_keyCurrentUserId);
  }

  Future<void> setCurrentUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(_keyCurrentUserId);
    } else {
      await _prefs.setString(_keyCurrentUserId, userId);
    }
  }

  UserModel? getCurrentUser() {
    final id = getCurrentUserId();
    if (id == null) return null;
    final users = getAllUsers();
    return users.where((u) => u.id == id).firstOrNull;
  }

  // --- User-Isolated Storage Keys ---

  String _userKey(String suffix) {
    final uid = getCurrentUserId() ?? 'guest';
    return 'quant_${uid}_$suffix';
  }

  // Wallet
  double getWalletBalance() {
    return _prefs.getDouble(_userKey('wallet_balance')) ?? AppConstants.initialVirtualCash;
  }

  Future<void> saveWalletBalance(double balance) async {
    await _prefs.setDouble(_userKey('wallet_balance'), balance);
  }

  // Positions
  List<PositionModel> getPositions() {
    final raw = _prefs.getString(_userKey('positions'));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => PositionModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePositions(List<PositionModel> positions) async {
    final raw = jsonEncode(positions.map((e) => e.toJson()).toList());
    await _prefs.setString(_userKey('positions'), raw);
  }

  // Orders
  List<OrderModel> getOrders() {
    final raw = _prefs.getString(_userKey('orders'));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    final raw = jsonEncode(orders.map((e) => e.toJson()).toList());
    await _prefs.setString(_userKey('orders'), raw);
  }

  // Transactions
  List<TransactionModel> getTransactions() {
    final raw = _prefs.getString(_userKey('transactions'));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final raw = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _prefs.setString(_userKey('transactions'), raw);
  }

  // Closed Trades
  List<ClosedTradeModel> getClosedTrades() {
    final raw = _prefs.getString(_userKey('closed_trades'));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ClosedTradeModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveClosedTrades(List<ClosedTradeModel> trades) async {
    final raw = jsonEncode(trades.map((e) => e.toJson()).toList());
    await _prefs.setString(_userKey('closed_trades'), raw);
  }

  // Watchlist Symbols
  List<String> getWatchlistSymbols() {
    return _prefs.getStringList(_userKey('watchlist')) ?? ['AAPL', 'NVDA', 'TSLA', 'MSFT', 'AMZN'];
  }

  Future<void> saveWatchlistSymbols(List<String> symbols) async {
    await _prefs.setStringList(_userKey('watchlist'), symbols);
  }

  // Price Alerts
  List<PriceAlertModel> getAlerts() {
    final raw = _prefs.getString(_userKey('alerts'));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => PriceAlertModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAlerts(List<PriceAlertModel> alerts) async {
    final raw = jsonEncode(alerts.map((e) => e.toJson()).toList());
    await _prefs.setString(_userKey('alerts'), raw);
  }

  // Registered Leagues
  List<String> getRegisteredLeagues() {
    return _prefs.getStringList(_keyRegisteredLeagues) ?? ['league-1'];
  }

  Future<void> saveRegisteredLeagues(List<String> ids) async {
    await _prefs.setStringList(_keyRegisteredLeagues, ids);
  }

  // Completed Lessons
  List<String> getCompletedLessons() {
    return _prefs.getStringList(_userKey('completed_lessons')) ?? [];
  }

  Future<void> saveCompletedLessons(List<String> lessonIds) async {
    await _prefs.setStringList(_userKey('completed_lessons'), lessonIds);
  }

  // Theme
  bool isDarkMode() {
    return _prefs.getBool(_keyThemeMode) ?? true;
  }

  Future<void> saveDarkMode(bool isDark) async {
    await _prefs.setBool(_keyThemeMode, isDark);
  }

  // Reset User specific state
  Future<void> resetUserState() async {
    await _prefs.remove(_userKey('wallet_balance'));
    await _prefs.remove(_userKey('positions'));
    await _prefs.remove(_userKey('orders'));
    await _prefs.remove(_userKey('transactions'));
    await _prefs.remove(_userKey('closed_trades'));
  }
}
