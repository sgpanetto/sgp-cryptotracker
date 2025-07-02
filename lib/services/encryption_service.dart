import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  late final Encrypter _encrypter;
  late final IV _iv;

  EncryptionService(String password) {
    // Genera una chiave di 32 byte dal password
    final keyBytes = utf8.encode(password);
    final hash = sha256.convert(keyBytes);
    final key = Key.fromBase64(base64.encode(hash.bytes));
    
    // IV fisso per semplicità (in produzione dovrebbe essere casuale)
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(key));
  }

  String encrypt(String text) {
    if (text.isEmpty) return text;
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      // Se la decrittografia fallisce, restituisci il testo originale
      return encryptedText;
    }
  }
} 