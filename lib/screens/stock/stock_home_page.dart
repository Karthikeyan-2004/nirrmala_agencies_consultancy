import 'package:flutter/material.dart';
import '../../widgets/stock/stock_form.dart';
import '../../widgets/stock/stock_calculator.dart';
import 'stock_notifications_page.dart';
import '../../services/storage_service.dart';
import '../settings_page.dart';

class StockHomePage extends StatefulWidget {
  const StockHomePage({super.key});

  @override
  State<StockHomePage> createState() => _StockHomePageState();
}

class _StockHomePageState extends State<StockHomePage> {
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Screw',
      'image': 'assets/images/screw.jpg',
    },
    {
      'name': 'Plyboard',
      'image': 'assets/images/plyboard.jpg',
    },
    {
      'name': 'Tiles',
      'image': 'assets/images/tiles.jpg',
    }
  ];
  String? selectedProduct;
  DateTime? selectedDate;
  final TextEditingController _openingStockController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _batchNumberController = TextEditingController();
  Map<String, int> openingStock = {};
  Map<String, List<Map<String, dynamic>>> stockData = {};
  Map<String, String> openingStockDate = {};
  List<String> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      openingStock = await StorageService.loadOpeningStock();
      openingStockDate = await StorageService.loadOpeningStockDates();
      stockData = await StorageService.loadStockData();
      notifications = await StorageService.loadNotifications();
    } catch (e) {
      _showToast("Error loading data: $e", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    try {
      await StorageService.saveOpeningStock(openingStock);
      await StorageService.saveOpeningStockDates(openingStockDate);
      await StorageService.saveStockData(stockData);
      await StorageService.saveNotifications(notifications);
    } catch (e) {
      _showToast("Error saving data: $e", Colors.red);
    }
  }

  @override
  void dispose() {
    _openingStockController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _batchNumberController.dispose();
    super.dispose();
  }

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _setOpeningStock() async {
    if (selectedProduct != null && selectedDate != null) {
      setState(() {
        openingStock[selectedProduct!] = int.tryParse(_openingStockController.text) ?? 0;
        openingStockDate[selectedProduct!] = selectedDate!.toIso8601String().split('T')[0];
        stockData[selectedProduct!] = [];
      });

      String message = "✅ Opening Stock of ${openingStock[selectedProduct!]} set for ${selectedProduct!} on ${selectedDate!.toIso8601String().split('T')[0]}.";

      _showToast(message, Colors.green);
      _addNotification(message);
      
      await _saveData();
    }
  }

  void _addStock(bool isIncoming) async {
    if (selectedProduct == null || selectedDate == null) return;

    int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) return;

    String formattedDate = selectedDate!.toIso8601String().split('T')[0];
    String? notes = _notesController.text.isNotEmpty ? _notesController.text : null;
  String? batchNumber = _batchNumberController.text.isNotEmpty ? _batchNumberController.text : null;
    setState(() {
      stockData[selectedProduct!]?.add({
        'date': formattedDate,
        'quantity': quantity,
        'type': isIncoming ? 'incoming' : 'outgoing',
        'notes': _notesController.text,
        'batchNumber': _batchNumberController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    int newStock = _calculateClosingStock();

    String message = "${isIncoming ? '➕ Added' : '➖ Removed'} $quantity ${isIncoming ? 'incoming' : 'outgoing'} stock for ${selectedProduct!} on $formattedDate. 📦 New stock: $newStock.";

    _showToast(message, isIncoming ? Colors.green : Colors.red);
    _addNotification(message);
    
    // Clear input fields
    _quantityController.clear();
    _notesController.clear();
    _batchNumberController.clear();
    
    await _saveData();
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNotification(String message) {
    setState(() {
      notifications.insert(0, message);
    });
  }

  int _calculateClosingStock() {
    if (selectedProduct == null || selectedDate == null) return 0;

    String? opDateString = openingStockDate[selectedProduct!];
    if (opDateString == null) return 0;

    DateTime openingDate = DateTime.parse(opDateString);

    if (selectedDate!.isBefore(openingDate)) {
      return 0;
    }

    int currentStock = openingStock[selectedProduct!] ?? 0;

    for (DateTime date = openingDate;
        date.isBefore(selectedDate!.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      
      String formattedDate = date.toIso8601String().split('T')[0];

      for (var entry in stockData[selectedProduct!] ?? []) {
        if (entry['date'] == formattedDate) {
          if (entry['type'] == 'incoming') {
            currentStock += (entry['quantity'] as num).toInt();
          } else {
            currentStock -= (entry['quantity'] as num).toInt();
          }
        }
      }
    }

    return currentStock;
  }

  Future<void> _clearAllData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear all stock data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.clearAllData();
              setState(() {
                openingStock = {};
                openingStockDate = {};
                stockData = {};
                notifications = [];
                selectedProduct = null;
                selectedDate = null;
                _openingStockController.clear();
                _quantityController.clear();
                _notesController.clear();
                _batchNumberController.clear();
              });
              _showToast('All data has been cleared', Colors.orange);
            },
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Maintenance'),
        actions: [
          IconButton(
  icon: const Icon(Icons.settings),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          onDataCleared: () {
            setState(() {
              openingStock = {};
              openingStockDate = {};
              stockData = {};
              notifications = [];
              selectedProduct = null;
              selectedDate = null;
              _openingStockController.clear();
              _quantityController.clear();
              _notesController.clear();
              _batchNumberController.clear();
            });
          },
          onDataRestored: () {
            _loadData();
          },
        ),
      ),
    );
  },
),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockNotificationsPage(notifications: notifications),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllData,
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: StockForm(
    products: products,
    selectedProduct: selectedProduct,
    selectedDate: selectedDate,
    openingStockController: _openingStockController,
    quantityController: _quantityController,
    notesController: _notesController,
    batchNumberController: _batchNumberController,
    openingStock: openingStock,
    stockData: stockData,
    onProductChanged: (value) {
      setState(() {
        selectedProduct = value;
        selectedDate = null;
        _openingStockController.clear();
        _quantityController.clear();
        _notesController.clear();
        _batchNumberController.clear();
      });
    },
    onDatePicked: _pickDate,
    onSetOpeningStock: _setOpeningStock,
    onAddStock: _addStock,
    onCalculateClosingStock: _calculateClosingStock,
  ),
),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockCalculator(
                onCalculate: _calculateClosingStock,
  selectedProduct: selectedProduct,
              ),
            ),
          );
        },
        child: const Icon(Icons.calculate),
      ),
    );
  }
}
