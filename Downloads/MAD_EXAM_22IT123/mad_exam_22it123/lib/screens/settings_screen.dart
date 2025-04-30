import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mad_exam_22it123/providers/card_provider.dart';
import 'package:mad_exam_22it123/services/notification_service.dart';
import 'package:mad_exam_22it123/services/sync_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _expiryAlertsEnabled = true;
  bool _biometricAuthEnabled = false;
  bool _isLoading = false;
  bool _isOnline = true;
  bool _isSyncing = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkConnectivity();
  }
  
  Future<void> _loadSettings() async {
    // In a real app, these would be loaded from shared preferences or other storage
    setState(() {
      _pushNotificationsEnabled = true;
      _expiryAlertsEnabled = true;
      _biometricAuthEnabled = false;
    });
  }
  
  // check internet connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
    
    // listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!mounted) return;
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
      
      // trigger sync when coming back online
      if (_isOnline) {
        _syncData();
      }
    });
  }
  
  // sync data with server
  Future<void> _syncData() async {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are offline')),
      );
      return;
    }
    
    setState(() {
      _isSyncing = true;
    });
    
    try {
      await Provider.of<CardProvider>(context, listen: false).syncWithServer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
  
  Future<void> _togglePushNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would request permission for notifications here
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _pushNotificationsEnabled = value;
        if (!value) {
          // If push notifications are disabled, also disable expiry alerts
          _expiryAlertsEnabled = false;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling notifications: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleExpiryAlerts(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would update user preferences and notification settings
      await Future.delayed(const Duration(milliseconds: 300));
      
      setState(() {
        _expiryAlertsEnabled = value;
        if (value && !_pushNotificationsEnabled) {
          // If enabling expiry alerts, also enable push notifications
          _pushNotificationsEnabled = true;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling expiry alerts: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometricAuth(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, you would check for biometric support and set up authentication
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Simulate biometric authorization - in a real app would use local_auth
      if (value) {
        final hasAuth = await _simulateBiometricPrompt();
        if (!hasAuth) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
      
      setState(() {
        _biometricAuthEnabled = value;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling biometric auth: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Simulate biometric prompt - in a real app would use local_auth
  Future<bool> _simulateBiometricPrompt() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Simulate Biometric Auth'),
            content: const Text(
                'In a real app, this would show a system biometric prompt. Enable biometric auth?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Authenticate'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, would export data to a file
      await Future.delayed(const Duration(seconds: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllCards() async {
    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Cards?'),
        content: const Text(
          'Are you sure you want to delete all your loyalty cards? '
          'This cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      // Get all card IDs
      final cardIds = cardProvider.cards.map((card) => card.id).toList();
      
      // Delete each card
      for (final id in cardIds) {
        await cardProvider.deleteCard(id);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All cards deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete cards: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load sample cards
  Future<void> _loadSampleCards() async {
    // Confirm loading sample cards
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Load Sample Cards?'),
        content: const Text(
          'This will replace all your existing cards with sample cards. '
          'Are you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Load Samples'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      await cardProvider.resetAndLoadSampleCards();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample cards loaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sample cards: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openHelpPage() async {
    // In a real app, would open a help page or documentation
    final Uri url = Uri.parse('https://example.com/help');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open help page')),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Loyalty Card Storage',
        applicationVersion: '1.0.0',
        applicationIcon: const Icon(
          Icons.credit_card,
          size: 48,
          color: Colors.blue,
        ),
        children: [
          const Text(
            'A simple app to store and manage all your loyalty cards in one place. '
            'Never forget or lose a loyalty card again!',
          ),
          const SizedBox(height: 16),
          const Text('© 2023 Card Storage Inc.'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    final cardCount = cardProvider.cards.length;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // App Settings Section
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      // Push Notifications
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        secondary: const Icon(Icons.notifications),
                        value: _pushNotificationsEnabled,
                        onChanged: _togglePushNotifications,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      
                      // Expiry Alerts
                      SwitchListTile(
                        title: const Text('Expiry Alerts'),
                        secondary: const Icon(Icons.alarm),
                        value: _expiryAlertsEnabled,
                        onChanged: _pushNotificationsEnabled
                            ? _toggleExpiryAlerts
                            : null,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      
                      // Biometric Authentication
                      SwitchListTile(
                        title: const Text('Biometric Authentication'),
                        secondary: const Icon(Icons.fingerprint),
                        value: _biometricAuthEnabled,
                        onChanged: _toggleBiometricAuth,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Data Management Section
                const Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      // Export Data
                      ListTile(
                        leading: const Icon(Icons.share, color: Colors.blue),
                        title: const Text('Export Data'),
                        onTap: _exportData,
                      ),
                      
                      // Load Sample Cards
                      ListTile(
                        leading: const Icon(Icons.add_circle, color: Colors.green),
                        title: const Text('Load Sample Cards'),
                        subtitle: const Text('Add sample cards in all categories'),
                        onTap: _loadSampleCards,
                      ),
                      
                      // Delete All Cards
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Delete All Cards', 
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: _deleteAllCards,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // About Section
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      // Help & Support
                      ListTile(
                        leading: const Icon(Icons.help, color: Colors.blue),
                        title: const Text('Help & Support'),
                        onTap: _openHelpPage,
                      ),
                      
                      // About This App
                      ListTile(
                        leading: const Icon(Icons.info, color: Colors.blue),
                        title: const Text('About This App'),
                        onTap: _showAboutDialog,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Your Stats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have $cardCount loyalty cards stored in this app.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 