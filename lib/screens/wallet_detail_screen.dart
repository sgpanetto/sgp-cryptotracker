import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/wallet_address.dart';
import '../models/app_settings.dart';
import '../widgets/crypto_detail_screen.dart';
import 'package:intl/intl.dart';

class WalletDetailScreen extends StatelessWidget {
  final WalletAddress wallet;

  const WalletDetailScreen({
    super.key,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.alias),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false)
                  .refreshWalletBalances(wallet);
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final walletBalances = appProvider.cryptoBalances
              .where((balance) => balance.walletAddressId == wallet.id)
              .toList();

          return Column(
            children: [
              // Header con info wallet
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getBlockchainColor(wallet.blockchainType),
                      _getBlockchainColor(wallet.blockchainType).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        wallet.blockchainType.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      wallet.alias,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatAddress(wallet.address),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${walletBalances.length} criptovalute',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista crypto
              Expanded(
                child: walletBalances.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: walletBalances.length,
                        itemBuilder: (context, index) {
                          final balance = walletBalances[index];
                          return _buildCryptoCard(context, balance, appProvider.settings);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna criptovaluta trovata',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Questo wallet potrebbe essere vuoto o non supportato',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false)
                  .refreshWalletBalances(wallet);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Aggiorna Saldi'),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(
    BuildContext context,
    dynamic balance,
    AppSettings settings,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            balance.symbol.substring(0, 2).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          balance.symbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${balance.balance.toStringAsFixed(6)} ${balance.symbol}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(
                settings.fiatCurrency == FiatCurrency.eur
                    ? balance.valueEur
                    : balance.valueUsd,
                settings.fiatCurrency,
              ),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CryptoDetailScreen(
                symbol: balance.symbol,
                balances: [balance],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  String _formatCurrency(double value, FiatCurrency currency) {
    final formatter = NumberFormat.currency(
      locale: currency == FiatCurrency.eur ? 'it_IT' : 'en_US',
      symbol: currency == FiatCurrency.eur ? '€' : '\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  Color _getBlockchainColor(String blockchainType) {
    switch (blockchainType.toLowerCase()) {
      case 'ethereum':
        return Colors.blue;
      case 'bitcoin':
        return Colors.orange;
      case 'solana':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
} 