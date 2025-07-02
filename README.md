# SGP CryptoTracker

Un'applicazione Flutter per monitorare e tracciare i valori delle criptovalute associate ai tuoi wallet pubblici.

## Caratteristiche

### 🔐 Sicurezza
- **Crittografia dei dati**: Tutti i dati sensibili sono criptati nel database locale
- **Autenticazione biometrica**: Supporto per impronta digitale e Face ID
- **Password sicura**: Hash con salt per la protezione delle credenziali

### 📊 Monitoraggio Crypto
- **Valore totale aggregato**: Visualizzazione del valore totale in EUR/USD
- **Multi-blockchain**: Supporto per Ethereum, Bitcoin, Solana e altre blockchain
- **Aggregazione intelligente**: Le stesse crypto su diversi protocolli vengono sommate
- **API gratuite**: Utilizzo di API pubbliche senza costi (Ethplorer, Blockchair, Solscan, CoinGecko)

### 🎨 Interfaccia Utente
- **Design moderno**: Material Design 3 con temi chiari/scuri
- **Navigazione intuitiva**: Bottom navigation bar con 3 sezioni principali
- **Responsive**: Ottimizzata per diversi dispositivi Android

### ⚙️ Funzionalità Avanzate
- **Gestione wallet**: Aggiunta, rimozione e visualizzazione dettagliata dei wallet
- **Export/Import**: Backup e ripristino del database criptato
- **Aggiornamenti automatici**: Refresh dei saldi con un tap
- **Riconoscimento automatico**: Rilevamento automatico del tipo di blockchain dall'indirizzo

## Sezioni dell'App

### 🏠 Home
- Valore totale delle criptovalute in FIAT
- Lista aggregata delle crypto per simbolo
- Dettagli espandibili per protocollo

### 💼 Wallet
- Lista degli indirizzi wallet configurati
- Valore totale per ogni wallet
- Dettagli delle crypto per wallet specifico
- Aggiunta nuovi wallet con QR scanner

### ⚙️ Impostazioni
- Selezione valuta FIAT (EUR/USD)
- Gestione tema (Chiaro/Scuro/Automatico)
- Configurazione autenticazione biometrica
- Export/Import database
- Forza refresh dei saldi

## Tecnologie Utilizzate

- **Flutter**: Framework cross-platform
- **SQLite**: Database locale con crittografia
- **Provider**: State management
- **Crypto**: Crittografia AES per i dati sensibili
- **Local Auth**: Autenticazione biometrica
- **HTTP/Dio**: Chiamate API blockchain
- **File Picker**: Gestione file per export/import

## API Blockchain Supportate

- **Ethereum/EVM**: Ethplorer (gratuita)
- **Bitcoin**: Blockchair (gratuita)
- **Solana**: Solscan (gratuita)
- **Prezzi Crypto**: CoinGecko (gratuita)

## Installazione

1. **Clona il repository**:
   ```bash
   git clone <repository-url>
   cd sgp_cryptotracker
   ```

2. **Installa le dipendenze**:
   ```bash
   flutter pub get
   ```

3. **Esegui l'applicazione**:
   ```bash
   flutter run
   ```

## Configurazione Iniziale

1. **Primo avvio**: L'app ti guiderà nella configurazione iniziale
2. **Crea password**: Imposta una password per criptare i dati
3. **Biometrica (opzionale)**: Abilita l'autenticazione biometrica se disponibile
4. **Aggiungi wallet**: Inizia ad aggiungere i tuoi indirizzi wallet

## Utilizzo

### Aggiungere un Wallet
1. Vai alla sezione "Wallet"
2. Tocca il bottone "+" 
3. Inserisci un alias (es. "Wallet Principale")
4. Inserisci l'indirizzo del wallet
5. L'app rileverà automaticamente il tipo di blockchain

### Visualizzare i Saldi
1. I saldi si aggiornano automaticamente all'apertura dell'app
2. Usa il bottone refresh per aggiornamenti manuali
3. Tocca su una crypto per vedere i dettagli per protocollo

### Backup e Ripristino
1. Vai in Impostazioni
2. Usa "Esporta Database" per il backup
3. Usa "Importa Database" per il ripristino

## Sicurezza

- **Dati locali**: Tutti i dati sono salvati localmente sul dispositivo
- **Crittografia AES**: Indirizzi wallet e alias sono criptati
- **Password hash**: Le password sono hashate con salt
- **Nessuna condivisione**: I dati non vengono mai inviati a server esterni

## Limitazioni

- **API gratuite**: Rate limit delle API pubbliche per uso personale
- **Blockchain supportate**: Ethereum, Bitcoin, Solana (altre in sviluppo)
- **Dispositivi**: Ottimizzata per Android (iOS in sviluppo)

## Sviluppo Futuro

- [ ] Supporto per più blockchain (Polygon, BSC, etc.)
- [ ] Notifiche per variazioni di prezzo
- [ ] Grafici e statistiche
- [ ] Supporto iOS
- [ ] QR scanner per indirizzi
- [ ] Widget per la home screen

## Licenza

Questo progetto è per uso personale. Non utilizzare per scopi commerciali senza autorizzazione.

## Autore

Simone Graziano Panetto - SGP CryptoTracker v1.0
