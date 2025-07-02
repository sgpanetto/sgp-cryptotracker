import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/wallet_address.dart';
import '../models/crypto_balance.dart';
import '../models/app_settings.dart';
import 'encryption_service.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late EncryptionService _encryptionService;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize(String password) async {
    _encryptionService = EncryptionService(password);
    await database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'sgp_cryptotracker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabella wallet_addresses
    await db.execute('''
      CREATE TABLE wallet_addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alias TEXT NOT NULL,
        address TEXT NOT NULL,
        blockchainType TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Tabella crypto_balances
    await db.execute('''
      CREATE TABLE crypto_balances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        walletAddressId INTEGER NOT NULL,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        blockchainType TEXT NOT NULL,
        balance REAL NOT NULL,
        priceUsd REAL,
        priceEur REAL,
        lastUpdated INTEGER NOT NULL,
        FOREIGN KEY (walletAddressId) REFERENCES wallet_addresses (id) ON DELETE CASCADE
      )
    ''');

    // Tabella app_settings
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fiatCurrency INTEGER NOT NULL,
        theme INTEGER NOT NULL,
        biometricEnabled INTEGER NOT NULL,
        lastDataRefresh INTEGER NOT NULL
      )
    ''');

    // Inserisci impostazioni di default
    final defaultSettings = AppSettings.defaultSettings;
    await db.insert('app_settings', defaultSettings.toMap());
  }

  // Wallet Addresses
  Future<int> insertWalletAddress(WalletAddress wallet) async {
    final db = await database;
    final encryptedWallet = wallet.copyWith(
      alias: _encryptionService.encrypt(wallet.alias),
      address: _encryptionService.encrypt(wallet.address),
    );
    return await db.insert('wallet_addresses', encryptedWallet.toMap());
  }

  Future<List<WalletAddress>> getAllWalletAddresses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wallet_addresses');
    return List.generate(maps.length, (i) {
      final decryptedMap = Map<String, dynamic>.from(maps[i]);
      decryptedMap['alias'] = _encryptionService.decrypt(maps[i]['alias']);
      decryptedMap['address'] = _encryptionService.decrypt(maps[i]['address']);
      return WalletAddress.fromMap(decryptedMap);
    });
  }

  Future<WalletAddress?> getWalletAddressById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_addresses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    
    final decryptedMap = Map<String, dynamic>.from(maps.first);
    decryptedMap['alias'] = _encryptionService.decrypt(maps.first['alias']);
    decryptedMap['address'] = _encryptionService.decrypt(maps.first['address']);
    return WalletAddress.fromMap(decryptedMap);
  }

  Future<int> updateWalletAddress(WalletAddress wallet) async {
    final db = await database;
    final encryptedWallet = wallet.copyWith(
      alias: _encryptionService.encrypt(wallet.alias),
      address: _encryptionService.encrypt(wallet.address),
    );
    return await db.update(
      'wallet_addresses',
      encryptedWallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> deleteWalletAddress(int id) async {
    final db = await database;
    return await db.delete(
      'wallet_addresses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Crypto Balances
  Future<int> insertCryptoBalance(CryptoBalance balance) async {
    final db = await database;
    return await db.insert('crypto_balances', balance.toMap());
  }

  Future<List<CryptoBalance>> getCryptoBalancesByWalletId(int walletId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'crypto_balances',
      where: 'walletAddressId = ?',
      whereArgs: [walletId],
    );
    return List.generate(maps.length, (i) => CryptoBalance.fromMap(maps[i]));
  }

  Future<List<CryptoBalance>> getAllCryptoBalances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('crypto_balances');
    return List.generate(maps.length, (i) => CryptoBalance.fromMap(maps[i]));
  }

  Future<int> updateCryptoBalance(CryptoBalance balance) async {
    final db = await database;
    return await db.update(
      'crypto_balances',
      balance.toMap(),
      where: 'id = ?',
      whereArgs: [balance.id],
    );
  }

  Future<int> deleteCryptoBalancesByWalletId(int walletId) async {
    final db = await database;
    return await db.delete(
      'crypto_balances',
      where: 'walletAddressId = ?',
      whereArgs: [walletId],
    );
  }

  // App Settings
  Future<AppSettings> getAppSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('app_settings');
    if (maps.isEmpty) {
      final defaultSettings = AppSettings.defaultSettings;
      await db.insert('app_settings', defaultSettings.toMap());
      return defaultSettings;
    }
    return AppSettings.fromMap(maps.first);
  }

  Future<int> updateAppSettings(AppSettings settings) async {
    final db = await database;
    return await db.update(
      'app_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // Database Export/Import
  Future<String> exportDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
    
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, 'sgp_cryptotracker.db');
    
    return dbPath;
  }

  Future<void> importDatabase(String dbPath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String targetPath = join(documentsDirectory.path, 'sgp_cryptotracker.db');
    
    File sourceFile = File(dbPath);
    File targetFile = File(targetPath);
    
    await sourceFile.copy(targetPath);
    
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
} 