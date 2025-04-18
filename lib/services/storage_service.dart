import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_item.dart';

class StorageService {
  static const String OPENING_STOCK_KEY = 'opening_stock';
  static const String OPENING_STOCK_DATE_KEY = 'opening_stock_date';
  static const String STOCK_DATA_KEY = 'stock_data';
  static const String NOTIFICATIONS_KEY = 'notifications';

  // Save opening stock
  static Future<void> saveOpeningStock(Map<String, int> openingStock) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OPENING_STOCK_KEY, jsonEncode(openingStock));
  }

  // Load opening stock
  static Future<Map<String, int>> loadOpeningStock() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stockJson = prefs.getString(OPENING_STOCK_KEY);
    
    if (stockJson == null) return {};
    
    Map<String, dynamic> decoded = jsonDecode(stockJson);
    Map<String, int> result = {};
    
    decoded.forEach((key, value) {
      result[key] = value as int;
    });
    
    return result;
  }

  // Save opening stock dates
  static Future<void> saveOpeningStockDates(Map<String, String> dates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OPENING_STOCK_DATE_KEY, jsonEncode(dates));
  }

  // Load opening stock dates
  static Future<Map<String, String>> loadOpeningStockDates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? datesJson = prefs.getString(OPENING_STOCK_DATE_KEY);
    
    if (datesJson == null) return {};
    
    Map<String, dynamic> decoded = jsonDecode(datesJson);
    Map<String, String> result = {};
    
    decoded.forEach((key, value) {
      result[key] = value as String;
    });
    
    return result;
  }

  // Save stock data
  static Future<void> saveStockData(Map<String, List<Map<String, dynamic>>> stockData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(STOCK_DATA_KEY, jsonEncode(stockData));
  }

  // Load stock data
  static Future<Map<String, List<Map<String, dynamic>>>> loadStockData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataJson = prefs.getString(STOCK_DATA_KEY);
    
    if (dataJson == null) return {};
    
    Map<String, dynamic> decoded = jsonDecode(dataJson);
    Map<String, List<Map<String, dynamic>>> result = {};
    
    decoded.forEach((key, value) {
      List<Map<String, dynamic>> items = [];
      for (var item in value) {
        items.add(Map<String, dynamic>.from(item));
      }
      result[key] = items;
    });
    
    return result;
  }

  // Save notifications
  static Future<void> saveNotifications(List<String> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(NOTIFICATIONS_KEY, notifications);
  }

  // Load notifications
  static Future<List<String>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(NOTIFICATIONS_KEY) ?? [];
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
