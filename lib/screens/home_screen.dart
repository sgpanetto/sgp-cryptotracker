import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/app_settings.dart';
import '../models/crypto_balance.dart';
import '../widgets/crypto_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SGP CryptoTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false).refreshAllBalances();
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalValue = appProvider.totalValue;
          final aggregatedBalances = appProvider.aggregatedCryptoBalances;

          return Column(
            children: [
              // Sezione valore totale (circa un terzo della schermata)
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Valore Totale',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(totalValue, appProvider.settings.fiatCurrency),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${aggregatedBalances.length} criptovalute • ${appProvider.walletAddresses.length} wallet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista crypto aggregate
              Expanded(
                child: aggregatedBalances.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: aggregatedBalances.length,
                        itemBuilder: (context, index) {
                          final symbol = aggregatedBalances.keys.elementAt(index);
                          final balances = aggregatedBalances[symbol]!;
                          return _buildCryptoCard(context, symbol, balances, appProvider.settings);
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
            'Aggiungi un wallet per iniziare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Naviga alla sezione wallet
              DefaultTabController.of(context)?.animateTo(1);
            },
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Wallet'),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoCard(
    BuildContext context,
    String symbol,
    List<dynamic> balances,
    AppSettings settings,
  ) {
    double totalBalance = 0;
    double totalValue = 0;

    for (var balance in balances) {
      totalBalance += balance.balance;
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
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            symbol.substring(0, 2).toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '(${balances.length} protocolli)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${totalBalance.toStringAsFixed(6)} $symbol',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(totalValue, settings.fiatCurrency),
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
                symbol: symbol,
                balances: balances.cast<CryptoBalance>(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatCurrency(double value, FiatCurrency currency) {
    final formatter = NumberFormat.currency(
      locale: currency == FiatCurrency.eur ? 'it_IT' : 'en_US',
      symbol: currency == FiatCurrency.eur ? '€' : '\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
} 