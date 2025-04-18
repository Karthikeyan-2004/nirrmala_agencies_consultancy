import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static Future<void> createBackup() async {
    try {
      // Get all data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> backupData = {};
      
      // Get all keys
      Set<String> keys = prefs.getKeys();
      
      // Add each key-value pair to the backup data
      for (String key in keys) {
        // Check the type of the value and handle accordingly
        if (prefs.getString(key) != null) {
          backupData[key] = prefs.getString(key);
        } else if (prefs.getStringList(key) != null) {
          backupData[key] = prefs.getStringList(key);
        } else if (prefs.getInt(key) != null) {
          backupData[key] = prefs.getInt(key);
        } else if (prefs.getBool(key) != null) {
          backupData[key] = prefs.getBool(key);
        } else if (prefs.getDouble(key) != null) {
          backupData[key] = prefs.getDouble(key);
        }
      }
      
      // Convert to JSON
      String jsonData = jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'data': backupData,
      });
      
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'nirrmala_agencies_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final path = '${directory.path}/$fileName';
      
      // Write to file
      final file = File(path);
      await file.writeAsString(jsonData);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Nirrmala Agencies Data Backup',
      );
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<bool> restoreBackup() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) {
        return false;
      }
      
      // Read file
      final path = result.files.single.path;
      if (path == null) return false;
      
      final file = File(path);
      final jsonData = await file.readAsString();
      
      // Parse JSON
      final Map<String, dynamic> backupData = jsonDecode(jsonData);
      
      // Validate backup data
      if (!backupData.containsKey('timestamp') || !backupData.containsKey('data')) {
        throw Exception('Invalid backup file format');
      }
      
      // Get SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Clear existing data
      await prefs.clear();
      
      // Restore data
      final Map<String, dynamic> data = backupData['data'];
      
      for (String key in data.keys) {
        var value = data[key];
        
        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List) {
          await prefs.setStringList(key, List<String>.from(value));
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        }
      }
      
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
