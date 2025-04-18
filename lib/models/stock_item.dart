// class StockItem {
//   final String date;
//   final int quantity;
//   final String type;

//   StockItem({
//     required this.date,
//     required this.quantity,
//     required this.type,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'date': date,
//       'quantity': quantity,
//       'type': type,
//     };
//   }
// }


class StockItem {
  final String date;
  final int quantity;
  final String type;
  final String? notes;
  final String? batchNumber;
  final DateTime timestamp;

  StockItem({
    required this.date,
    required this.quantity,
    required this.type,
    this.notes,
    this.batchNumber,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'quantity': quantity,
      'type': type,
      'notes': notes,
      'batchNumber': batchNumber,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      date: map['date'],
      quantity: map['quantity'],
      type: map['type'],
      notes: map['notes'],
      batchNumber: map['batchNumber'],
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : null,
    );
  }
}
