
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/services/vault_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final VaultService _vaultService = VaultService();
  final TextEditingController _pinController = TextEditingController();
  bool _isPinSet = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    _isPinSet = await _vaultService.isPinSet();
    setState(() {});
  }

  Future<void> _authenticate() async {
    bool authenticated = await _vaultService.authenticate();
    if (authenticated) {
      // Navigate to vault content
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authenticated successfully!')),
      );
      // In a real app, you'd navigate to the vault content view
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed.')),
      );
    }
  }

  Future<void> _setPin() async {
    if (_pinController.text.isNotEmpty) {
      await _vaultService.setPin(_pinController.text);
      _checkPinStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN set successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN cannot be empty.')),
      );
    }
  }

  Future<void> _verifyPin() async {
    if (_pinController.text.isNotEmpty) {
      bool verified = await _vaultService.verifyPin(_pinController.text);
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN verified successfully!')),
        );
        // Navigate to vault content
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter PIN.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Vault'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isPinSet)
              Column(
                children: [
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Set PIN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _setPin,
                    child: const Text('Set PIN'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter PIN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _verifyPin,
                    child: const Text('Verify PIN'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Authenticate with Biometrics'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
