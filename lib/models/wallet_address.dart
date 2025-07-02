class WalletAddress {
  final int? id;
  final String alias;
  final String address;
  final String blockchainType;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletAddress({
    this.id,
    required this.alias,
    required this.address,
    required this.blockchainType,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alias': alias,
      'address': address,
      'blockchainType': blockchainType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WalletAddress.fromMap(Map<String, dynamic> map) {
    return WalletAddress(
      id: map['id'],
      alias: map['alias'],
      address: map['address'],
      blockchainType: map['blockchainType'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  WalletAddress copyWith({
    int? id,
    String? alias,
    String? address,
    String? blockchainType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletAddress(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      address: address ?? this.address,
      blockchainType: blockchainType ?? this.blockchainType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 