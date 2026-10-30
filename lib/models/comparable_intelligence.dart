class ComparableIntelligence {
  final int comparableCount;
  final double lowPrice;
  final double highPrice;
  final double averagePrice;
  final double medianPrice;
  final double priceSpread;
  final double spreadPercent;
  final double marketValueDifference;
  final double marketValueDifferencePercent;
  final String consistency;
  final String evidenceStrength;
  final String valuationBasis;
  final int relevantComparableCount;
  final int excludedComparableCount;
  final String relevanceQuality;
  final List<dynamic> relevantItems;

  const ComparableIntelligence({
    required this.comparableCount,
    required this.lowPrice,
    required this.highPrice,
    required this.averagePrice,
    required this.medianPrice,
    required this.priceSpread,
    required this.spreadPercent,
    required this.marketValueDifference,
    required this.marketValueDifferencePercent,
    required this.consistency,
    required this.evidenceStrength,
    required this.valuationBasis,
    required this.relevantComparableCount,
    required this.excludedComparableCount,
    required this.relevanceQuality,
    required this.relevantItems,
  });
}