import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/app_settings.dart';
import '../services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await AuthService().isBiometricAvailable();
    setState(() {
      _biometricAvailable = available;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Sezione Preferenze
              _buildSection(
                'Preferenze',
                [
                  _buildCurrencySelector(appProvider),
                  _buildThemeSelector(appProvider),
                  if (_biometricAvailable) _buildBiometricToggle(appProvider),
                ],
              ),
              const SizedBox(height: 24),

              // Sezione Dati
              _buildSection(
                'Gestione Dati',
                [
                  _buildRefreshButton(appProvider),
                  _buildExportButton(appProvider),
                  _buildImportButton(appProvider),
                ],
              ),
              const SizedBox(height: 24),

              // Sezione Informazioni
              _buildSection(
                'Informazioni',
                [
                  _buildInfoTile('Versione App', '1.0.0'),
                  _buildInfoTile('Ultimo Aggiornamento', _formatDate(appProvider.settings.lastDataRefresh)),
                  _buildInfoTile('Wallet Configurati', '${appProvider.walletAddresses.length}'),
                  _buildInfoTile('Criptovalute Trovate', '${appProvider.cryptoBalances.length}'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(AppProvider appProvider) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Valuta FIAT'),
      subtitle: Text(
        appProvider.settings.fiatCurrency == FiatCurrency.eur ? 'EUR (€)' : 'USD (\$)',
      ),
      trailing: DropdownButton<FiatCurrency>(
        value: appProvider.settings.fiatCurrency,
        onChanged: (FiatCurrency? newValue) {
          if (newValue != null) {
            final newSettings = appProvider.settings.copyWith(fiatCurrency: newValue);
            appProvider.updateSettings(newSettings);
          }
        },
        items: FiatCurrency.values.map((FiatCurrency currency) {
          return DropdownMenuItem<FiatCurrency>(
            value: currency,
            child: Text(currency == FiatCurrency.eur ? 'EUR' : 'USD'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeSelector(AppProvider appProvider) {
    String themeText;
    switch (appProvider.settings.theme) {
      case AppTheme.light:
        themeText = 'Chiaro';
        break;
      case AppTheme.dark:
        themeText = 'Scuro';
        break;
      case AppTheme.auto:
        themeText = 'Automatico';
        break;
    }

    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Tema'),
      subtitle: Text(themeText),
      trailing: DropdownButton<AppTheme>(
        value: appProvider.settings.theme,
        onChanged: (AppTheme? newValue) {
          if (newValue != null) {
            final newSettings = appProvider.settings.copyWith(theme: newValue);
            appProvider.updateSettings(newSettings);
          }
        },
        items: AppTheme.values.map((AppTheme theme) {
          String text;
          switch (theme) {
            case AppTheme.light:
              text = 'Chiaro';
              break;
            case AppTheme.dark:
              text = 'Scuro';
              break;
            case AppTheme.auto:
              text = 'Automatico';
              break;
          }
          return DropdownMenuItem<AppTheme>(
            value: theme,
            child: Text(text),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBiometricToggle(AppProvider appProvider) {
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: const Text('Autenticazione Biometrica'),
      subtitle: const Text('Usa impronta digitale o Face ID'),
      value: appProvider.settings.biometricEnabled,
      onChanged: (bool value) async {
        final authService = AuthService();
        if (value) {
          await authService.enableBiometric();
        } else {
          await authService.disableBiometric();
        }
        final newSettings = appProvider.settings.copyWith(biometricEnabled: value);
        appProvider.updateSettings(newSettings);
      },
    );
  }

  Widget _buildRefreshButton(AppProvider appProvider) {
    return ListTile(
      leading: const Icon(Icons.refresh),
      title: const Text('Forza il refresh sui valori dei wallet'),
      subtitle: const Text('Aggiorna immediatamente tutti i saldi'),
      onTap: appProvider.isLoading ? null : () {
        appProvider.refreshAllBalances();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aggiornamento avviato...'),
          ),
        );
      },
      trailing: appProvider.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
    );
  }

  Widget _buildExportButton(AppProvider appProvider) {
    return ListTile(
      leading: const Icon(Icons.upload),
      title: const Text('Esporta Database'),
      subtitle: const Text('Salva una copia criptata del database'),
      onTap: () async {
        try {
          final dbPath = await appProvider.exportDatabase();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Database esportato in: $dbPath'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'esportazione: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildImportButton(AppProvider appProvider) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('Importa Database'),
      subtitle: const Text('Carica un database esistente'),
      onTap: () async {
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['db'],
          );

          if (result != null) {
            final filePath = result.files.single.path;
            if (filePath != null) {
              await appProvider.importDatabase(filePath);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Database importato con successo'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'importazione: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
} 