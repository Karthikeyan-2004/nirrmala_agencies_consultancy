import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class StockCalculator extends StatelessWidget {
  final int Function() onCalculate;
  final String? selectedProduct;

  const StockCalculator({
    super.key,
    required this.onCalculate,
    required this.selectedProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {
          int closingStock = onCalculate();
          showGeneralDialog(
            context: context,
            pageBuilder: (_, animation, __) => Container(),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              var curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
              return ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(curve),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curve),
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 8,
                    child: buildStockResultDialog(context, closingStock),
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calculate_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Calculate Stock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStockResultDialog(BuildContext context, int closingStock) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with animated icon
          buildAnimatedStockIcon(context),
          
          const SizedBox(height: 24),
          
          // Product name
          Text(
            selectedProduct ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Date
          Text(
            'As of today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stock result
          buildStockResultCard(context, closingStock),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('Print'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Print functionality would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Print functionality not implemented yet')),
                  );
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget buildAnimatedStockIcon(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: math.sin(value * math.pi) * 0.2 + 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }
  
  Widget buildStockResultCard(BuildContext context, int closingStock) {
    final Color stockColor = closingStock > 10 
        ? Colors.green 
        : closingStock > 5 
            ? Colors.orange 
            : Colors.red;
            
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: stockColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stockColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Current Stock',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                closingStock > 10 
                    ? Icons.check_circle 
                    : closingStock > 5 
                        ? Icons.warning 
                        : Icons.error,
                color: stockColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                closingStock.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: stockColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            getStockStatusMessage(closingStock),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: stockColor,
            ),
          ),
        ],
      ),
    );
  }
  
  String getStockStatusMessage(int stock) {
    if (stock <= 0) {
      return 'Out of stock! Order immediately.';
    } else if (stock <= 5) {
      return 'Low stock! Consider reordering soon.';
    } else if (stock <= 10) {
      return 'Moderate stock level.';
    } else {
      return 'Good stock level.';
    }
  }
}
