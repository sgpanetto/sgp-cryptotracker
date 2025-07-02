import 'package:flutter/material.dart';
import '../models/crypto_balance.dart';
import '../models/app_settings.dart';
import 'package:intl/intl.dart';

class CryptoDetailScreen extends StatelessWidget {
  final String symbol;
  final List<CryptoBalance> balances;

  const CryptoDetailScreen({
    super.key,
    required this.symbol,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio $symbol'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: balances.length,
        itemBuilder: (context, index) {
          final balance = balances[index];
          return _buildProtocolCard(context, balance);
        },
      ),
    );
  }

  Widget _buildProtocolCard(BuildContext context, CryptoBalance balance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getBlockchainColor(balance.blockchainType),
              child: Text(
                balance.blockchainType.substring(0, 2).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance.blockchainType.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    balance.name,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${balance.balance.toStringAsFixed(6)} $symbol',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '\$${balance.valueUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '€${balance.valueEur.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow('Prezzo USD', '\$${balance.priceUsd?.toStringAsFixed(4) ?? 'N/A'}'),
                _buildDetailRow('Prezzo EUR', '€${balance.priceEur?.toStringAsFixed(4) ?? 'N/A'}'),
                _buildDetailRow('Ultimo aggiornamento', _formatDate(balance.lastUpdated)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
} 