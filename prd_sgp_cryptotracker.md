# SGP CryptoTracker - Product Requirements Document (PRD)


**Versione:** 1.0
**Data:** 30 Giugno 2025
**Autore:** Simone Graziano Panetto


---


## 1. Introduzione


[cite_start]SGP CryptoTracker è un'applicazione mobile sviluppata in Flutter, inizialmente destinata alla piattaforma Android, con potenziale espansione futura per iOS e Windows[cite: 1]. [cite_start]Lo scopo principale dell'app è consentire agli utenti di monitorare e tracciare i valori delle diverse criptovalute associate alle loro chiavi pubbliche, che verranno inserite manualmente[cite: 2]. L'applicazione mira a fornire una panoramica aggregata e dettagliata delle holding di criptovalute di un utente.


## 2. Obiettivi del Prodotto


* Fornire una piattaforma intuitiva per il monitoraggio delle criptovalute su diverse blockchain.
* Aggregare e visualizzare il valore totale delle criptovalute possedute in valuta FIAT (EUR/USD).
* Permettere una gestione semplice e sicura degli indirizzi wallet pubblici.
* Garantire la sicurezza dei dati sensibili degli utenti tramite crittografia.


## 3. Destinatari


* **Team di Sviluppo:** Per comprendere i requisiti funzionali e non funzionali.
* **Designer UI/UX:** Per la progettazione dell'interfaccia utente e dell'esperienza.
* **QA Engineers:** Per la definizione dei casi di test e la verifica del prodotto.
* **Product Owner/Manager:** Per la roadmap del prodotto e la prioritizzazione.


## 4. Architettura Generale (Sezioni Principali dell'App)


L'applicazione sarà suddivisa in tre sezioni principali, accessibili tramite un sistema di navigazione (es. Bottom Navigation Bar):


1.  [cite_start]**Home** [cite: 3]
2.  [cite_start]**Lista indirizzi wallet** [cite: 3]
3.  [cite_start]**Impostazioni** [cite: 3]


## 5. Requisiti Dettagliati


### 5.1. Sezione Home


* **Visualizzazione Valore Totale FIAT:**
    * [cite_start]La parte superiore (circa un terzo) della schermata mostrerà il valore totale aggregato in valuta FIAT (es. EUR o USD) di tutte le criptovalute scansionate dagli indirizzi registrati nell'app[cite: 4].
* **Lista Crypto Dettagliata:**
    * [cite_start]La parte restante della pagina conterrà una lista scorrevole di tutte le criptovalute trovate sugli indirizzi, raggruppate per tipo di crypto e aggregate tra i vari protocolli supportati (es. Ethereum, Bitcoin, Arbitrum, Base, Polygon, Solana, ecc.)[cite: 4].
    * [cite_start]Se la stessa criptovaluta è presente su due o più protocolli (es. USDT su Arbitrum e USDT su Polygon), i valori saranno sommati e visualizzati come un'unica voce (es. "USDT 15")[cite: 5].
* **Interazione con le Voci della Lista:**
    * [cite_start]Ogni voce nella lista delle crypto sarà cliccabile[cite: 6].
    * [cite_start]Al click, si aprirà una schermata di dettaglio che visualizzerà la criptovaluta suddivisa per i protocolli su cui è presente[cite: 6].
    * Le voci di dettaglio saranno espandibili al click, mostrando:
        * [cite_start]L'alias abbinato all'indirizzo specifico da cui proviene la crypto[cite: 6].
        * [cite_start]Il valore atomico (esatto) di quella criptovaluta su quel particolare wallet e per quel singolo protocollo[cite: 6].


### 5.2. Sezione Lista indirizzi wallet


* **Elenco Indirizzi:**
    * [cite_start]Questa sezione conterrà una lista degli indirizzi pubblici inseriti dall'utente, ognuno associato a un alias definito dall'utente[cite: 7].
    * [cite_start]Ogni voce della lista mostrerà l'Alias dell'indirizzo, l'indirizzo effettivo sottostante e, sulla destra, il valore totale in FIAT di tutte le criptovalute presenti su quell'indirizzo (sommando i valori da tutti i protocolli)[cite: 8].
* **Interazione con le Voci degli Indirizzi:**
    * [cite_start]Ogni singola voce della lista degli indirizzi sarà cliccabile[cite: 9].
    * Al click, si aprirà una pagina di dettaglio specifica per quell'indirizzo. Questa pagina mostrerà l'elenco delle criptovalute presenti sull'indirizzo in modo analogo alla sezione Home, ma filtrato per il singolo indirizzo selezionato. [cite_start]Il comportamento delle voci delle criptovalute e dei loro dettagli sarà identico a quello della Home[cite: 9].
* **Aggiunta Nuovo Indirizzo:**
    * [cite_start]Sarà presente un bottone "Inserisci nuovo indirizzo"[cite: 7].
    * [cite_start]Al click sul bottone, si aprirà un form per l'inserimento di un nuovo indirizzo pubblico[cite: 10].
    * [cite_start]Il form includerà un campo per l'Alias (nome descrittivo) e un campo per l'Indirizzo pubblico[cite: 10].
    * [cite_start]Il campo Indirizzo potrà essere popolato sia tramite digitazione manuale da tastiera, sia tramite la scansione di un codice QR, attivabile da un'icona posta a destra del campo del form[cite: 11].
    * [cite_start]L'applicazione dovrà essere in grado di interpretare automaticamente il tipo di indirizzo inserito (es. Bitcoin, BNB Chain, Solana, EVM compatible, ecc.)[cite: 12].


### 5.3. Sezione Impostazioni


Questa sezione permetterà all'utente di configurare diverse preferenze dell'applicazione:


* **Gestione Valuta FIAT:**
    * [cite_start]Un selettore a tendina consentirà all'utente di scegliere la valuta FIAT da utilizzare per visualizzare i valori (EUR o USD)[cite: 13, 14].
* **Selezione Tema:**
    * [cite_start]Un selettore a tendina permetterà di cambiare il tema dell'interfaccia utente tra "Scuro", "Chiaro" e "Automatico" (basato sulle impostazioni di sistema del dispositivo)[cite: 14].
* **Forza Refresh:**
    * [cite_start]Un bottone con etichetta "Forza il refresh sui valori dei wallet" che, al click, avvierà una scansione immediata dei dati[cite: 14].
* **Gestione Database:**
    * [cite_start]**Esporta DB:** Un bottone per esportare il database criptato dell'app (es. per backup)[cite: 14].
    * [cite_start]**Importa DB:** Un bottone per importare un database esistente[cite: 14].


## 6. Requisiti Funzionali Core / Trasversali


* **Scansione Dati Crypto:**
    * [cite_start]La scansione dei valori delle criptovalute deve essere effettuata utilizzando vari tracker Blockchain (API pubbliche o private)[cite: 15].
    * [cite_start]La scansione può essere eseguita una volta al giorno automaticamente, all'apertura dell'applicazione[cite: 16].
* **Sicurezza e Crittografia Dati:**
    * [cite_start]Le informazioni sensibili relative agli indirizzi wallet devono essere criptate all'interno del database locale dell'app[cite: 17].
* **Gestione Primo Avvio e Autenticazione:**
    * [cite_start]Al primo avvio dell'applicazione, all'utente verrà chiesto se desidera importare un database esistente o inizializzarne uno nuovo[cite: 17].
    * [cite_start]**Nuovo DB:** Se si sceglie di creare un nuovo database, l'app richiederà l'inserimento di una password e la sua ripetizione per la crittografia dei dati[cite: 18].
    * [cite_start]**Import DB:** Se si sceglie di importare un database esistente, l'app richiederà la password associata a quel database per decriptare i dati[cite: 19].
    * **Accesso Successivo:** Dopo la prima configurazione, l'app dovrà prevedere l'accesso tramite la password impostata o, in alternativa, direttamente tramite l'autenticazione biometrica (impronta digitale), per evitare di dover reinserire la password ogni volta per decriptare i dati.


## 7. Requisiti Non Funzionali


* **Prestazioni:** Le operazioni di scansione e aggregazione dei dati devono essere rapide ed efficienti per garantire un'esperienza utente fluida.
* **Sicurezza:** Massima attenzione alla sicurezza dei dati degli utenti, in particolare per le informazioni sugli indirizzi e le password, tramite algoritmi di crittografia robusti.
* [cite_start]**Scalabilità:** La codebase deve essere strutturata per facilitare l'espansione futura su piattaforme iOS e Windows[cite: 1]. La gestione dei protocolli blockchain deve essere estendibile.
* **Usabilità:** L'interfaccia utente deve essere intuitiva e facile da navigare, anche per utenti con poca familiarità con il mondo crypto.
* **Affidabilità:** I dati visualizzati (valori crypto) devono essere accurati e aggiornati con la frequenza specificata.
* **Compatibilità:** Funzionamento ottimale su un'ampia gamma di dispositivi Android.


## 8. Tecnologie (Già delineate)


* [cite_start]**Flutter:** Per lo sviluppo dell'applicazione cross-platform[cite: 1].
* **Database locale criptato:** Per la memorizzazione sicura delle chiavi pubbliche e degli alias.
* **API Blockchain Explorer:** Integrazione con API di terze parti per recuperare i saldi degli indirizzi su vari protocolli (es. Etherscan, SolScan, Blockchair, etc.).


---