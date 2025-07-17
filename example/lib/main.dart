import 'package:flutter/material.dart';
import 'package:ussd_launcher/ussd_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _ussdResult = 'Aucun résultat';
  bool _isLoading = false;
  bool _hasCallPermission = false;

  @override
  void initState() {
    super.initState();
    _checkCallPermission();
    _setupUssdListener();
  }

  void _setupUssdListener() {
    UssdLauncher.setUssdMessageListener((String message) {
      setState(() {
        _ussdResult = message;
      });
    });
  }

  Future<void> _checkCallPermission() async {
    bool hasPermission = await UssdLauncher.isCallPermissionGranted();
    setState(() {
      _hasCallPermission = hasPermission;
    });
  }

  Future<void> _requestCallPermission() async {
    bool granted = await UssdLauncher.requestCallPermission();
    setState(() {
      _hasCallPermission = granted;
    });
  }

  Future<void> _sendUssdRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? result = await UssdLauncher.sendUssdRequest(
        ussdCode: '*100#',
        subscriptionId: 0,
      );

      setState(() {
        _ussdResult = result ?? 'Aucune réponse';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ussdResult = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMultisessionUssd() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? result = await UssdLauncher.multisessionUssd(
        code: '*100#',
        slotIndex: 0,
        options: ['1', '2', '3'],
      );

      setState(() {
        _ussdResult = result ?? 'Aucune réponse';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ussdResult = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('USSD Launcher Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut de l\'autorisation d\'appel:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _hasCallPermission
                                ? Icons.check_circle
                                : Icons.error,
                            color:
                                _hasCallPermission ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                              _hasCallPermission ? 'Autorisé' : 'Non autorisé'),
                        ],
                      ),
                      if (!_hasCallPermission) ...[
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _requestCallPermission,
                          child: const Text('Demander l\'autorisation'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendUssdRequest,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Envoyer requête USSD simple'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendMultisessionUssd,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Envoyer requête USSD multi-étapes'),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Résultat USSD:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_ussdResult),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
