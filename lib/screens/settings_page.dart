import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import '../services/storage_service.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback onDataCleared;
  final VoidCallback onDataRestored;

  const SettingsPage({
    super.key,
    required this.onDataCleared,
    required this.onDataRestored,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.backup, color: Colors.blue),
            ),
            title: const Text('Backup Data'),
            subtitle: const Text('Create a backup of all your data'),
            onTap: () async {
              try {
                await BackupService.createBackup();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup created successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Backup failed: $e')),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restore, color: Colors.green),
            ),
            title: const Text('Restore Data'),
            subtitle: const Text('Restore data from a backup file'),
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restore Data'),
                  content: const Text(
                    'Restoring will replace all current data with the backup data. This cannot be undone. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          bool success = await BackupService.restoreBackup();
                          if (success) {
                            onDataRestored();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data restored successfully')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Restore failed: $e')),
                          );
                        }
                      },
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all data from the app'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Data'),
                  content: const Text(
                    'Are you sure you want to clear all data? This action cannot be undone.',
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
                        onDataCleared();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All data has been cleared')),
                        );
                      },
                      child: const Text('Clear All Data'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
