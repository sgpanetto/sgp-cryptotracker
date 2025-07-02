import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/wallet_address.dart';
import '../models/app_settings.dart';
import 'add_wallet_screen.dart';
import 'wallet_detail_screen.dart';
import 'package:intl/intl.dart';

class WalletListScreen extends StatelessWidget {
  const WalletListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Wallet'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final wallets = appProvider.walletAddresses;
          final cryptoBalances = appProvider.cryptoBalances;

          if (wallets.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              final walletBalances = cryptoBalances
                  .where((balance) => balance.walletAddressId == wallet.id)
                  .toList();
              
              return _buildWalletCard(
                context,
                wallet,
                walletBalances,
                appProvider.settings,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddWalletScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
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
            'Nessun wallet aggiunto',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggiungi il tuo primo wallet per iniziare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddWalletScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Wallet'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    WalletAddress wallet,
    List<dynamic> balances,
    AppSettings settings,
  ) {
    double totalValue = 0;
    for (var balance in balances) {
      if (settings.fiatCurrency == FiatCurrency.eur) {
        totalValue += balance.valueEur;
      } else {
        totalValue += balance.valueUsd;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getBlockchainColor(wallet.blockchainType),
          child: Text(
            wallet.blockchainType.substring(0, 2).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          wallet.alias,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatAddress(wallet.address),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${balances.length} criptovalute',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(totalValue, settings.fiatCurrency),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              wallet.blockchainType.toUpperCase(),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalletDetailScreen(wallet: wallet),
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