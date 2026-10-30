class ResellRadarVerdict {
  final String verdictLabel;
  final String verdictMessage;

  final String dealStrengthLabel;
  final String historicalSupportLabel;

  final double dealScore;
  final double roiPercent;

  final String opportunityTier;
  final String dealRecommendation;

  final String historicalConfidence;
  final String historicalRisk;
  final String historicalBuyZone;
  final String historicalMomentum;
  final String historicalEntryTiming;

  const ResellRadarVerdict({
    required this.verdictLabel,
    required this.verdictMessage,
    required this.dealStrengthLabel,
    required this.historicalSupportLabel,
    required this.dealScore,
    required this.roiPercent,
    required this.opportunityTier,
    required this.dealRecommendation,
    required this.historicalConfidence,
    required this.historicalRisk,
    required this.historicalBuyZone,
    required this.historicalMomentum,
    required this.historicalEntryTiming,
  });

  bool get isStrongBuy =>
      verdictLabel == 'STRONG BUY';

  bool get isPositive =>
      verdictLabel == 'STRONG BUY' ||
      verdictLabel == 'BUY';

  bool get isCaution =>
      verdictLabel == 'PROCEED WITH CAUTION';

  bool get isPass =>
      verdictLabel == 'PASS';
}