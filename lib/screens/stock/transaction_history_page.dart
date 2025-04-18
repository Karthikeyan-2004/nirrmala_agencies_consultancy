import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatelessWidget {
  final String productName;
  final List<Map<String, dynamic>> transactions;

  const TransactionHistoryPage({
    super.key,
    required this.productName,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // Sort transactions by timestamp (newest first)
    final sortedTransactions = List<Map<String, dynamic>>.from(transactions)
      ..sort((a, b) {
        DateTime aTime = DateTime.parse(a['timestamp'] ?? DateTime.now().toIso8601String());
        DateTime bTime = DateTime.parse(b['timestamp'] ?? DateTime.now().toIso8601String());
        return bTime.compareTo(aTime);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text('$productName Transactions'),
      ),
      body: sortedTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transactions will appear here once created',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sortedTransactions.length,
              itemBuilder: (context, index) {
                final transaction = sortedTransactions[index];
                final isIncoming = transaction['type'] == 'incoming';
                final quantity = transaction['quantity'] as int;
                final date = transaction['date'] as String;
                final notes = transaction['notes'] as String?;
                final batchNumber = transaction['batchNumber'] as String?;
                final timestamp = DateTime.parse(
                    transaction['timestamp'] ?? DateTime.now().toIso8601String());

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isIncoming ? Colors.green.shade200 : Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isIncoming ? Colors.green.shade100 : Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncoming ? Icons.add_circle : Icons.remove_circle,
                        color: isIncoming ? Colors.green : Colors.red,
                        size: 28,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          isIncoming ? 'Incoming' : 'Outgoing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncoming ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '($quantity units)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text('Date: $date'),
                          ],
                        ),
                        if (batchNumber != null && batchNumber.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.batch_prediction, size: 16),
                              const SizedBox(width: 4),
                              Text('Batch: $batchNumber'),
                            ],
                          ),
                        ],
                        if (notes != null && notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.note, size: 16),
                              const SizedBox(width: 4),
                              Expanded(child: Text('Notes: $notes')),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Time: ${DateFormat('MMM d, yyyy - h:mm a').format(timestamp)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
