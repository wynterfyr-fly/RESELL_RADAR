class PriceSnapshot {
  final double marketValue;
  final double lowestPrice;
  final double averagePrice;
  final double medianPrice;
  final double highestPrice;

  final int listingsChecked;
  final String confidence;

  final DateTime recordedAt;

  const PriceSnapshot({
    required this.marketValue,
    required this.lowestPrice,
    required this.averagePrice,
    required this.medianPrice,
    required this.highestPrice,
    required this.listingsChecked,
    required this.confidence,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'marketValue': marketValue,
      'lowestPrice': lowestPrice,
      'averagePrice': averagePrice,
      'medianPrice': medianPrice,
      'highestPrice': highestPrice,
      'listingsChecked': listingsChecked,
      'confidence': confidence,
      'recordedAt':
          recordedAt.toIso8601String(),
    };
  }

  factory PriceSnapshot.fromMap(
    Map<String, dynamic> map,
  ) {
    return PriceSnapshot(
      marketValue:
          (map['marketValue'] ?? 0)
              .toDouble(),
      lowestPrice:
          (map['lowestPrice'] ?? 0)
              .toDouble(),
      averagePrice:
          (map['averagePrice'] ?? 0)
              .toDouble(),
      medianPrice:
          (map['medianPrice'] ?? 0)
              .toDouble(),
      highestPrice:
          (map['highestPrice'] ?? 0)
              .toDouble(),
      listingsChecked:
          map['listingsChecked'] ?? 0,
      confidence:
          map['confidence'] ??
          'Unknown',
      recordedAt:
          DateTime.tryParse(
            map['recordedAt'] ?? '',
          ) ??
          DateTime.now(),
    );
  }
}