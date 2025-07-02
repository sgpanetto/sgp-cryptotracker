import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/blockchain_service.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _addressController = TextEditingController();
  String _detectedBlockchain = '';

  @override
  void dispose() {
    _aliasController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Alias
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(
                  labelText: 'Alias',
                  hintText: 'Es. Wallet Principale, Cold Storage, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un alias per il wallet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Indirizzo
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Indirizzo Wallet',
                  hintText: 'Incolla o digita l\'indirizzo del wallet',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanQRCode,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci l\'indirizzo del wallet';
                  }
                  return null;
                },
                onChanged: _onAddressChanged,
              ),
              const SizedBox(height: 16),

              // Blockchain rilevata
              if (_detectedBlockchain.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Blockchain rilevata: $_detectedBlockchain',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Bottone aggiungi
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return ElevatedButton(
                    onPressed: appProvider.isLoading ? null : _addWallet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: appProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Aggiungi Wallet'),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Messaggio di errore
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  if (appProvider.error != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        appProvider.error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddressChanged(String address) {
    if (address.isNotEmpty) {
      final blockchain = BlockchainService.detectBlockchainType(address);
      setState(() {
        _detectedBlockchain = blockchain.toUpperCase();
      });
    } else {
      setState(() {
        _detectedBlockchain = '';
      });
    }
  }

  Future<void> _scanQRCode() async {
    // Per ora mostro un messaggio, implementerò il QR scanner successivamente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanner QR in sviluppo'),
      ),
    );
  }

  Future<void> _addWallet() async {
    if (!_formKey.currentState!.validate()) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final success = await appProvider.addWalletAddress(
      _aliasController.text,
      _addressController.text,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet aggiunto con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 