import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/stock_item.dart';
import 'package:fl_chart/fl_chart.dart';

class StockHistory extends StatelessWidget {
  final String productName;
  final List<StockItem> stockItems;

  const StockHistory({
    super.key,
    required this.productName,
    required this.stockItems,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.indigo.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history, size: 28, color: Colors.indigo),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$productName History',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${stockItems.length} transactions',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () => _showFullHistory(context),
                  tooltip: 'View full history',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (stockItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No stock movements recorded yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: buildStockChart(),
                  ),
                  const SizedBox(height: 20),
                  buildRecentTransactions(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildStockChart() {
    // This would require the fl_chart package
    // You would process stockItems to create chart data
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _createChartData(),
            isCurved: true,
            color: Colors.indigo,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.indigo.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createChartData() {
    // This is a simplified example - you would need to process your actual data
    // to create meaningful chart points
    final spots = <FlSpot>[];
    
    if (stockItems.isEmpty) return spots;
    
    // Sort items by date
    final sortedItems = List<StockItem>.from(stockItems)
      ..sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
    
    // Create running total
    int runningTotal = 0;
    for (int i = 0; i < sortedItems.length; i++) {
      final item = sortedItems[i];
      if (item.type == 'incoming') {
        runningTotal += item.quantity;
      } else {
        runningTotal -= item.quantity;
      }
      spots.add(FlSpot(i.toDouble(), runningTotal.toDouble()));
    }
    
    return spots;
  }

  Widget buildRecentTransactions() {
    final recentItems = stockItems.length > 5 
        ? stockItems.sublist(0, 5) 
        : stockItems;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recentItems.map((item) => buildTransactionItem(item)),
        if (stockItems.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('View All Transactions'),
                onPressed: () {},
              ),
            ),
          ),
      ],
    );
  }

  Widget buildTransactionItem(StockItem item) {
    final isIncoming = item.type == 'incoming';
    final date = DateTime.parse(item.date);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncoming ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncoming ? Icons.add : Icons.remove,
              color: isIncoming ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncoming ? 'Stock Added' : 'Stock Removed',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncoming ? '+' : '-'}${item.quantity}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncoming ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$productName Stock History',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: stockItems.length,
                  itemBuilder: (context, index) {
                    final item = stockItems[index];
                    return buildDetailedTransactionItem(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailedTransactionItem(StockItem item) {
    final isIncoming = item.type == 'incoming';
    final date = DateTime.parse(item.date);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isIncoming ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncoming ? Icons.add_circle : Icons.remove_circle,
                color: isIncoming ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIncoming ? 'Stock Added' : 'Stock Removed',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(date),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Note: ${item.notes}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Batch: ${item.batchNumber}',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${isIncoming ? '+' : '-'}${item.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isIncoming ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
