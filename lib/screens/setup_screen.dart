import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _enableBiometric = false;
  bool _isNewDatabase = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo e titolo
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'SGP CryptoTracker',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitora le tue criptovalute in modo sicuro',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Scelta tipo database
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurazione Database',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RadioListTile<bool>(
                          title: const Text('Nuovo Database'),
                          subtitle: const Text('Crea un nuovo database criptato'),
                          value: true,
                          groupValue: _isNewDatabase,
                          onChanged: (value) {
                            setState(() {
                              _isNewDatabase = value!;
                            });
                          },
                        ),
                        RadioListTile<bool>(
                          title: const Text('Importa Database'),
                          subtitle: const Text('Importa un database esistente'),
                          value: false,
                          groupValue: _isNewDatabase,
                          onChanged: (value) {
                            setState(() {
                              _isNewDatabase = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Campo password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Inserisci la password per criptare i dati',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una password';
                    }
                    if (value.length < 6) {
                      return 'La password deve essere di almeno 6 caratteri';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo conferma password (solo per nuovo database)
                if (_isNewDatabase) ...[
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Conferma Password',
                      hintText: 'Ripeti la password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Conferma la password';
                      }
                      if (value != _passwordController.text) {
                        return 'Le password non coincidono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Checkbox biometrica
                FutureBuilder<bool>(
                  future: AuthService().isBiometricAvailable(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!) {
                      return CheckboxListTile(
                        title: const Text('Abilita autenticazione biometrica'),
                        subtitle: const Text('Usa impronta digitale o Face ID'),
                        value: _enableBiometric,
                        onChanged: (value) {
                          setState(() {
                            _enableBiometric = value ?? false;
                          });
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 32),

                // Bottone continua
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return ElevatedButton(
                      onPressed: appProvider.isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: appProvider.isLoading
                          ? const CircularProgressIndicator()
                          : Text(_isNewDatabase ? 'Crea Database' : 'Importa Database'),
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
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    if (_isNewDatabase) {
      // Nuovo database
      final success = await appProvider.setupApp(
        _passwordController.text,
        _enableBiometric,
      );
      if (success) {
        _navigateToMain();
      }
    } else {
      // Import database - per ora mostro un messaggio
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funzionalità di import in sviluppo'),
        ),
      );
    }
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacementNamed('/main');
  }
} 