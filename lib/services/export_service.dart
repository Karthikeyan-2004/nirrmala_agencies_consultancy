import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  static Future<void> exportStockDataToCsv(
    String productName,
    List<Map<String, dynamic>> transactions,
    int openingStock,
  ) async {
    // Create CSV content
    StringBuffer csvContent = StringBuffer();
    
    // Add header
    csvContent.writeln('Stock Report for $productName');
    csvContent.writeln('Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    csvContent.writeln('');
    csvContent.writeln('Opening Stock: $openingStock');
    csvContent.writeln('');
    csvContent.writeln('Date,Type,Quantity,Batch Number,Notes,Timestamp');
    
    // Add transactions
    for (var transaction in transactions) {
      String date = transaction['date'] ?? '';
      String type = transaction['type'] ?? '';
      int quantity = transaction['quantity'] ?? 0;
      String batchNumber = transaction['batchNumber'] ?? '';
      String notes = transaction['notes'] ?? '';
      String timestamp = transaction['timestamp'] ?? '';
      
      csvContent.writeln('$date,$type,$quantity,"$batchNumber","$notes",$timestamp');
    }
    
    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${productName}_stock_report.csv';
    
    // Write to file
    final file = File(path);
    await file.writeAsString(csvContent.toString());
    
    // Share the file
    await Share.shareXFiles(
      [XFile(path)],
      subject: 'Stock Report for $productName',
    );
  }
}
