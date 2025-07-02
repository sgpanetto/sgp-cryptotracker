import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_balance.dart';
import '../models/wallet_address.dart';
import 'dart:math';

class BlockchainService {
  static const String _ethplorerApiKey = 'freekey';
  static const String _coingeckoApiUrl = 'https://api.coingecko.com/api/v3';
  static const String _blockchairApiUrl = 'https://api.blockchair.com/bitcoin/dashboards/address/';
  static const String _solscanApiUrl = 'https://public-api.solscan.io/account/tokens?address=';

  // Riconosce il tipo di blockchain dall'indirizzo
  static String detectBlockchainType(String address) {
    address = address.toLowerCase();
    if (address.startsWith('0x') && address.length == 42) {
      return 'ethereum';
    } else if (address.startsWith('1') || address.startsWith('3') || address.startsWith('bc1')) {
      return 'bitcoin';
    } else if (address.length == 44) {
      return 'solana';
    }
    return 'ethereum'; // Default
  }

  // Recupera i saldi per un indirizzo Ethereum/EVM (Ethplorer)
  Future<List<CryptoBalance>> getEthereumBalances(WalletAddress wallet) async {
    final List<CryptoBalance> balances = [];
    try {
      final url = 'https://api.ethplorer.io/getAddressInfo/${wallet.address}?apiKey=$_ethplorerApiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // ETH balance
        final ethBalance = (data['ETH']?['balance'] ?? 0.0).toDouble();
        if (ethBalance > 0) {
          final ethPrice = await _getCryptoPrice('ethereum');
          balances.add(CryptoBalance(
            walletAddressId: wallet.id!,
            symbol: 'ETH',
            name: 'Ethereum',
            blockchainType: 'ethereum',
            balance: ethBalance,
            priceUsd: ethPrice,
            priceEur: ethPrice * 0.92,
            lastUpdated: DateTime.now(),
          ));
        }
        // Token balances
        if (data['tokens'] != null) {
          for (var token in data['tokens']) {
            final tokenInfo = token['tokenInfo'];
            final symbol = tokenInfo['symbol'] ?? '';
            final name = tokenInfo['name'] ?? '';
            final decimals = int.tryParse(tokenInfo['decimals'] ?? '18') ?? 18;
            final balance = double.tryParse(token['balance'].toString()) ?? 0.0;
            final realBalance = balance / (pow(10, decimals));
            if (realBalance > 0) {
              final price = await _getCryptoPrice(symbol.toLowerCase());
              balances.add(CryptoBalance(
                walletAddressId: wallet.id!,
                symbol: symbol,
                name: name,
                blockchainType: 'ethereum',
                balance: realBalance,
                priceUsd: price,
                priceEur: price * 0.92,
                lastUpdated: DateTime.now(),
              ));
            }
          }
        }
      }
    } catch (e) {
      print('Errore Ethplorer: $e');
    }
    return balances;
  }

  // Recupera i saldi per un indirizzo Bitcoin (Blockchair)
  Future<List<CryptoBalance>> getBitcoinBalances(WalletAddress wallet) async {
    final List<CryptoBalance> balances = [];
    try {
      final url = '$_blockchairApiUrl${wallet.address}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressData = data['data']?[wallet.address]?['address'];
        if (addressData != null) {
          final satoshis = addressData['balance'] ?? 0;
          final btcBalance = satoshis / 100000000.0;
          if (btcBalance > 0) {
            final btcPrice = await _getCryptoPrice('bitcoin');
            balances.add(CryptoBalance(
              walletAddressId: wallet.id!,
              symbol: 'BTC',
              name: 'Bitcoin',
              blockchainType: 'bitcoin',
              balance: btcBalance,
              priceUsd: btcPrice,
              priceEur: btcPrice * 0.92,
              lastUpdated: DateTime.now(),
            ));
          }
        }
      }
    } catch (e) {
      print('Errore Blockchair: $e');
    }
    return balances;
  }

  // Recupera i saldi per un indirizzo Solana (Solscan)
  Future<List<CryptoBalance>> getSolanaBalances(WalletAddress wallet) async {
    final List<CryptoBalance> balances = [];
    try {
      final url = '$_solscanApiUrl${wallet.address}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        for (var token in data) {
          final symbol = token['tokenSymbol'] ?? '';
          final name = token['tokenName'] ?? '';
          final decimals = token['decimals'] ?? 0;
          final amount = double.tryParse(token['tokenAmount']?['uiAmount'].toString() ?? '0') ?? 0.0;
          if (amount > 0) {
            final price = await _getCryptoPrice(symbol.toLowerCase());
            balances.add(CryptoBalance(
              walletAddressId: wallet.id!,
              symbol: symbol,
              name: name,
              blockchainType: 'solana',
              balance: amount,
              priceUsd: price,
              priceEur: price * 0.92,
              lastUpdated: DateTime.now(),
            ));
          }
        }
      }
    } catch (e) {
      print('Errore Solscan: $e');
    }
    return balances;
  }

  // Recupera i prezzi delle criptovalute da CoinGecko (gratuito)
  Future<double> _getCryptoPrice(String symbol) async {
    try {
      final url = '$_coingeckoApiUrl/simple/price?ids=$symbol&vs_currencies=usd';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[symbol]?['usd'] ?? 0.0).toDouble();
      }
    } catch (e) {
      print('Errore CoinGecko: $e');
    }
    return 0.0;
  }

  // Recupera tutti i saldi per un wallet
  Future<List<CryptoBalance>> getWalletBalances(WalletAddress wallet) async {
    switch (wallet.blockchainType.toLowerCase()) {
      case 'ethereum':
        return await getEthereumBalances(wallet);
      case 'bitcoin':
        return await getBitcoinBalances(wallet);
      case 'solana':
        return await getSolanaBalances(wallet);
      default:
        return await getEthereumBalances(wallet);
    }
  }
} 