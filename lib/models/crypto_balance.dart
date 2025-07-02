class CryptoBalance {
  final int? id;
  final int walletAddressId;
  final String symbol;
  final String name;
  final String blockchainType;
  final double balance;
  final double? priceUsd;
  final double? priceEur;
  final DateTime lastUpdated;

  CryptoBalance({
    this.id,
    required this.walletAddressId,
    required this.symbol,
    required this.name,
    required this.blockchainType,
    required this.balance,
    this.priceUsd,
    this.priceEur,
    required this.lastUpdated,
  });

  double get valueUsd => (priceUsd ?? 0) * balance;
  double get valueEur => (priceEur ?? 0) * balance;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletAddressId': walletAddressId,
      'symbol': symbol,
      'name': name,
      'blockchainType': blockchainType,
      'balance': balance,
      'priceUsd': priceUsd,
      'priceEur': priceEur,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory CryptoBalance.fromMap(Map<String, dynamic> map) {
    return CryptoBalance(
      id: map['id'],
      walletAddressId: map['walletAddressId'],
      symbol: map['symbol'],
      name: map['name'],
      blockchainType: map['blockchainType'],
      balance: map['balance'],
      priceUsd: map['priceUsd'],
      priceEur: map['priceEur'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  CryptoBalance copyWith({
    int? id,
    int? walletAddressId,
    String? symbol,
    String? name,
    String? blockchainType,
    double? balance,
    double? priceUsd,
    double? priceEur,
    DateTime? lastUpdated,
  }) {
    return CryptoBalance(
      id: id ?? this.id,
      walletAddressId: walletAddressId ?? this.walletAddressId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      blockchainType: blockchainType ?? this.blockchainType,
      balance: balance ?? this.balance,
      priceUsd: priceUsd ?? this.priceUsd,
      priceEur: priceEur ?? this.priceEur,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
} 