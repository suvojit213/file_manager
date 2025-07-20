
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class VaultService {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  static const String _vaultPinKey = 'vault_pin';

  Future<bool> authenticate() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      debugPrint('Biometrics not available on this device.');
      return false;
    }

    List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      try {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Authenticate to access your secure vault',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        return authenticated;
      } catch (e) {
        debugPrint('Error during biometric authentication: $e');
        return false;
      }
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    await storage.write(key: _vaultPinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    String? storedPin = await storage.read(key: _vaultPinKey);
    return storedPin == pin;
  }

  Future<bool> isPinSet() async {
    return await storage.containsKey(key: _vaultPinKey);
  }

  // Placeholder for vault file operations (encryption/decryption)
  Future<void> encryptFile(String filePath, String vaultPath) async {
    debugPrint('Encrypting file: $filePath to $vaultPath');
    // Implement actual encryption logic here (e.g., using `encrypt` package)
    // For now, just simulate file movement
    // await File(filePath).rename(vaultPath);
  }

  Future<void> decryptFile(String vaultPath, String filePath) async {
    debugPrint('Decrypting file: $vaultPath to $filePath');
    // Implement actual decryption logic here
    // For now, just simulate file movement
    // await File(vaultPath).rename(filePath);
  }
}
