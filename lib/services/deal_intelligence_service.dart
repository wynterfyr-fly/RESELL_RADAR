import '../models/deal_intelligence.dart';

class DealIntelligenceService {
  DealIntelligence evaluate({
  required double marketValue,
  required double purchasePrice,
  double buyerShipping = 0.0,
  double buyerFees = 0.0,
  double salesTax = 0.0,
  required double estimatedFees,
  required double estimatedShipping,
  required String confidence,
}) {
    final trueAcquisitionCost =
    purchasePrice +
    buyerShipping +
    buyerFees +
    salesTax;

final estimatedProfit =
    marketValue -
    trueAcquisitionCost -
    estimatedFees -
    estimatedShipping;

    final roiPercent =
    trueAcquisitionCost > 0
        ? (estimatedProfit /
                trueAcquisitionCost) *
            100
        : 0.0;
            final confidenceBonus =
    switch (confidence) {
  'High' => 30.0,
  'Medium' => 20.0,
  'Low' => 10.0,
  'Very Low' => 5.0,
  _ => 0.0,
};

final profitBonus =
    estimatedProfit > 0
        ? 10.0
        : 0.0;

final roiScore =
    roiPercent.clamp(
  0.0,
  60.0,
);

final dealScore =
    (roiScore +
            confidenceBonus +
            profitBonus)
        .clamp(
  0.0,
  100.0,
);

final recommendation =
    switch (dealScore) {
  >= 85 => 'BUY NOW',
  >= 70 => 'GOOD DEAL',
  >= 50 => 'WAIT',
  >= 30 => 'HIGH RISK',
  _ => 'AVOID',
};

final opportunityTier =
    switch (dealScore) {
  >= 90 => 'S',
  >= 80 => 'A',
  >= 65 => 'B',
  >= 50 => 'C',
  >= 30 => 'D',
  _ => 'F',
};

    return DealIntelligence(
      marketValue:
          marketValue,
      purchasePrice:
          purchasePrice,
          buyerShipping:
      buyerShipping,
  buyerFees:
      buyerFees,
  salesTax:
      salesTax,
      estimatedFees:
          estimatedFees,
      estimatedShipping:
          estimatedShipping,
      estimatedProfit:
          estimatedProfit,
      roiPercent:
          roiPercent,
      dealScore:
    dealScore,
opportunityTier:
    opportunityTier,
recommendation:
    recommendation,
      confidence:
          confidence,
    );
  }
  double calculateSuggestedBuyPrice({
  required double marketValue,
  required double estimatedFees,
  required double estimatedShipping,
  double targetRoiPercent = 30,
}) {
  if (marketValue <= 0) {
    return 0;
  }

  final availableAfterCosts =
      marketValue -
      estimatedFees -
      estimatedShipping;

  if (availableAfterCosts <= 0) {
    return 0;
  }

  final roiMultiplier =
      1 +
      (targetRoiPercent / 100);

  final suggestedBuyPrice =
      availableAfterCosts /
      roiMultiplier;

  return suggestedBuyPrice < 0
      ? 0
      : suggestedBuyPrice;
}

double calculateSuggestedResalePrice({
  required double purchasePrice,
  required double estimatedShipping,
  double sellingFeeRate = 0.13,
  double targetRoiPercent = 30,
}) {
  if (purchasePrice <= 0) {
    return 0;
  }

  final targetProfit =
      purchasePrice *
      (targetRoiPercent / 100);

  final requiredAfterFees =
      purchasePrice +
      estimatedShipping +
      targetProfit;

  final feeMultiplier =
      1 - sellingFeeRate;

  if (feeMultiplier <= 0) {
    return 0;
  }

  return requiredAfterFees /
      feeMultiplier;
}
}