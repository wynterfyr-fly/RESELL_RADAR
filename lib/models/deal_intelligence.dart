class DealIntelligence {
  final double marketValue;
  final double purchasePrice;
  final double buyerShipping;
  final double buyerFees;
  final double salesTax;
  final double estimatedFees;
  final double estimatedShipping;

  final double estimatedProfit;
  final double roiPercent;

  final double dealScore;
  final String opportunityTier;

  final String recommendation;
  final String confidence;

  const DealIntelligence({
    required this.marketValue,
    required this.purchasePrice,
    this.buyerShipping = 0.0,
    this.buyerFees = 0.0,
    this.salesTax = 0.0,
    required this.estimatedFees,
    required this.estimatedShipping,
    required this.estimatedProfit,
    required this.roiPercent,
    required this.dealScore,
    this.opportunityTier = 'Unranked',
    required this.recommendation,
    required this.confidence,
  });

double get trueAcquisitionCost =>
    purchasePrice +
    buyerShipping +
    buyerFees +
    salesTax;

  double get totalCosts =>
    trueAcquisitionCost +
    estimatedFees +
    estimatedShipping;

  bool get isProfitable =>
      estimatedProfit > 0;

  bool get isStrongDeal =>
      dealScore >= 75;

  DealIntelligence copyWith({
    double? marketValue,
    double? purchasePrice,
    double? buyerShipping,
    double? buyerFees,
    double? salesTax,
    double? estimatedFees,
    double? estimatedShipping,
    double? estimatedProfit,
    double? roiPercent,
    double? dealScore,
    String? opportunityTier,
    String? recommendation,
    String? confidence,
  }) {
    return DealIntelligence(
      marketValue:
          marketValue ??
          this.marketValue,
      purchasePrice:
          purchasePrice ??
          this.purchasePrice,
          buyerShipping:
      buyerShipping ??
          this.buyerShipping,
      buyerFees:
          buyerFees ??
          this.buyerFees,
salesTax:
    salesTax ??
    this.salesTax,
      estimatedFees:
          estimatedFees ??
          this.estimatedFees,
      estimatedShipping:
          estimatedShipping ??
          this.estimatedShipping,
      estimatedProfit:
          estimatedProfit ??
          this.estimatedProfit,
      roiPercent:
          roiPercent ??
          this.roiPercent,
      dealScore:
    dealScore ??
    this.dealScore,
opportunityTier:
    opportunityTier ??
    this.opportunityTier,
recommendation:
    recommendation ??
    this.recommendation,
      confidence:
          confidence ??
          this.confidence,
    );
  }
}