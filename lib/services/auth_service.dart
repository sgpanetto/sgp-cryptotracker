import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _passwordKey = 'encrypted_password';
  static const String _saltKey = 'password_salt';

  // Verifica se l'autenticazione biometrica è disponibile
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Verifica se l'autenticazione biometrica è abilitata
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // Abilita l'autenticazione biometrica
  Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', true);
  }

  // Disabilita l'autenticazione biometrica
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', false);
  }

  // Autenticazione biometrica
  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Autenticati per accedere ai tuoi dati',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  // Salva la password criptata
  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = _generateSalt();
    final hashedPassword = _hashPassword(password, salt);
    
    await prefs.setString(_passwordKey, hashedPassword);
    await prefs.setString(_saltKey, salt);
  }

  // Verifica la password
  Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_passwordKey);
    final salt = prefs.getString(_saltKey);
    
    if (storedHash == null || salt == null) return false;
    
    final hashedPassword = _hashPassword(password, salt);
    return hashedPassword == storedHash;
  }

  // Verifica se esiste già una password
  Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey) != null;
  }

  // Genera un salt casuale
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Hash della password con salt
  String _hashPassword(String password, String salt) {
    final combined = password + salt;
    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);
    return base64.encode(hash.bytes);
  }

  // Verifica se è il primo avvio
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchCompleted = prefs.getBool('first_launch_completed');
    return firstLaunchCompleted != true;
  }

  // Marca il primo avvio come completato
  Future<void> markFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch_completed', true);
  }
} 