import 'package:flutter/material.dart';
import '../models/wallet_address.dart';
import '../models/crypto_balance.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';
import '../services/blockchain_service.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final BlockchainService _blockchainService = BlockchainService();
  final AuthService _authService = AuthService();

  List<WalletAddress> _walletAddresses = [];
  List<CryptoBalance> _cryptoBalances = [];
  AppSettings _settings = AppSettings.defaultSettings;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  // Getters
  List<WalletAddress> get walletAddresses => _walletAddresses;
  List<CryptoBalance> get cryptoBalances => _cryptoBalances;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  // Valore totale in FIAT
  double get totalValue {
    double total = 0;
    for (var balance in _cryptoBalances) {
      if (_settings.fiatCurrency == FiatCurrency.eur) {
        total += balance.valueEur;
      } else {
        total += balance.valueUsd;
      }
    }
    return total;
  }

  // Aggregazione crypto per simbolo
  Map<String, List<CryptoBalance>> get aggregatedCryptoBalances {
    final Map<String, List<CryptoBalance>> aggregated = {};
    
    for (var balance in _cryptoBalances) {
      if (!aggregated.containsKey(balance.symbol)) {
        aggregated[balance.symbol] = [];
      }
      aggregated[balance.symbol]!.add(balance);
    }
    
    return aggregated;
  }

  // Inizializzazione dell'app
  Future<bool> initializeApp() async {
    try {
      _setLoading(true);
      
      // Verifica se è il primo avvio
      final isFirstLaunch = await _authService.isFirstLaunch();
      if (isFirstLaunch) {
        return false; // Mostra schermata di setup
      }

      // Verifica autenticazione
      final hasPassword = await _authService.hasPassword();
      if (hasPassword) {
        final biometricEnabled = await _authService.isBiometricEnabled();
        if (biometricEnabled) {
          final authenticated = await _authService.authenticateWithBiometrics();
          if (!authenticated) {
            _setError('Autenticazione biometrica fallita');
            return false;
          }
        }
      }

      _isAuthenticated = true;
      await _loadData();
      return true;
    } catch (e) {
      _setError('Errore durante l\'inizializzazione: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Setup iniziale
  Future<bool> setupApp(String password, bool enableBiometric) async {
    try {
      _setLoading(true);
      
      // Salva password
      await _authService.savePassword(password);
      
      // Abilita biometrica se richiesto
      if (enableBiometric) {
        final biometricAvailable = await _authService.isBiometricAvailable();
        if (biometricAvailable) {
          await _authService.enableBiometric();
        }
      }

      // Inizializza database
      await _databaseService.initialize(password);
      
      // Marca primo avvio come completato
      await _authService.markFirstLaunchCompleted();
      
      _isAuthenticated = true;
      await _loadData();
      return true;
    } catch (e) {
      _setError('Errore durante il setup: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login con password
  Future<bool> loginWithPassword(String password) async {
    try {
      _setLoading(true);
      
      final isValid = await _authService.verifyPassword(password);
      if (!isValid) {
        _setError('Password non valida');
        return false;
      }

      await _databaseService.initialize(password);
      _isAuthenticated = true;
      await _loadData();
      return true;
    } catch (e) {
      _setError('Errore durante il login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Autenticazione biometrica
  Future<bool> authenticateWithBiometrics() async {
    try {
      final success = await _authService.authenticateWithBiometrics();
      if (success) {
        _isAuthenticated = true;
        await _loadData();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Errore durante l\'autenticazione biometrica: $e');
      return false;
    }
  }

  // Carica dati dal database
  Future<void> _loadData() async {
    try {
      _walletAddresses = await _databaseService.getAllWalletAddresses();
      _cryptoBalances = await _databaseService.getAllCryptoBalances();
      _settings = await _databaseService.getAppSettings();
      notifyListeners();
    } catch (e) {
      _setError('Errore nel caricamento dati: $e');
    }
  }

  // Aggiungi nuovo wallet
  Future<bool> addWalletAddress(String alias, String address) async {
    try {
      _setLoading(true);
      
      final blockchainType = BlockchainService.detectBlockchainType(address);
      final wallet = WalletAddress(
        alias: alias,
        address: address,
        blockchainType: blockchainType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _databaseService.insertWalletAddress(wallet);
      final newWallet = wallet.copyWith(id: id);
      
      _walletAddresses.add(newWallet);
      notifyListeners();
      
      // Aggiorna i saldi
      await refreshWalletBalances(newWallet);
      
      return true;
    } catch (e) {
      _setError('Errore nell\'aggiunta del wallet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Rimuovi wallet
  Future<bool> removeWalletAddress(int walletId) async {
    try {
      _setLoading(true);
      
      await _databaseService.deleteWalletAddress(walletId);
      _walletAddresses.removeWhere((w) => w.id == walletId);
      
      // Rimuovi anche i saldi associati
      await _databaseService.deleteCryptoBalancesByWalletId(walletId);
      _cryptoBalances.removeWhere((b) => b.walletAddressId == walletId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Errore nella rimozione del wallet: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Aggiorna saldi di un wallet
  Future<void> refreshWalletBalances(WalletAddress wallet) async {
    try {
      final balances = await _blockchainService.getWalletBalances(wallet);
      
      // Rimuovi saldi esistenti per questo wallet
      _cryptoBalances.removeWhere((b) => b.walletAddressId == wallet.id);
      
      // Aggiungi nuovi saldi
      for (var balance in balances) {
        final id = await _databaseService.insertCryptoBalance(balance);
        _cryptoBalances.add(balance.copyWith(id: id));
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento saldi: $e');
    }
  }

  // Aggiorna tutti i saldi
  Future<void> refreshAllBalances() async {
    try {
      _setLoading(true);
      
      for (var wallet in _walletAddresses) {
        await refreshWalletBalances(wallet);
      }
      
      // Aggiorna timestamp ultimo refresh
      _settings = _settings.copyWith(lastDataRefresh: DateTime.now());
      await _databaseService.updateAppSettings(_settings);
      
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento saldi: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Aggiorna impostazioni
  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      await _databaseService.updateAppSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      _setError('Errore nell\'aggiornamento impostazioni: $e');
    }
  }

  // Export database
  Future<String> exportDatabase() async {
    try {
      return await _databaseService.exportDatabase();
    } catch (e) {
      _setError('Errore nell\'esportazione del database: $e');
      rethrow;
    }
  }

  // Import database
  Future<void> importDatabase(String dbPath) async {
    try {
      await _databaseService.importDatabase(dbPath);
      await _loadData();
    } catch (e) {
      _setError('Errore nell\'importazione del database: $e');
      rethrow;
    }
  }

  // Verifica se esiste una password
  Future<bool> hasPassword() async {
    return await _authService.hasPassword();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 