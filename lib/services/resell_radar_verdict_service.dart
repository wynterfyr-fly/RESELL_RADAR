import '../models/deal_intelligence.dart';
import '../models/resell_radar_verdict.dart';
import 'historical_intelligence_service.dart';
import '../models/comparable_intelligence.dart';

class ResellRadarVerdictService {
  ResellRadarVerdict evaluate({
  required DealIntelligence deal,
  required HistoricalPricePosition historical,
  ComparableIntelligence? comparable,
}) {
    final dealStrengthLabel =
        _calculateDealStrength(
      deal,
    );

    final historicalSupportLabel =
        _calculateHistoricalSupport(
      historical,
    );

    final verdictLabel =
    _calculateVerdictLabel(
  deal: deal,
  historical: historical,
  comparable: comparable,
);

    final verdictMessage =
    _calculateVerdictMessage(
  verdictLabel: verdictLabel,
  deal: deal,
  historical: historical,
  comparable: comparable,
);

    return ResellRadarVerdict(
      verdictLabel:
          verdictLabel,
      verdictMessage:
          verdictMessage,
      dealStrengthLabel:
          dealStrengthLabel,
      historicalSupportLabel:
          historicalSupportLabel,
      dealScore:
          deal.dealScore,
      roiPercent:
          deal.roiPercent,
      opportunityTier:
          deal.opportunityTier,
      dealRecommendation:
          deal.recommendation,
      historicalConfidence:
          historical.confidenceLabel,
      historicalRisk:
          historical.riskLabel,
      historicalBuyZone:
          historical.buyZoneLabel,
      historicalMomentum:
          historical.momentumLabel,
      historicalEntryTiming:
          historical.entryTimingLabel,
    );
  }

  String _calculateDealStrength(
    DealIntelligence deal,
  ) {
    if (deal.dealScore >= 85) {
      return 'STRONG';
    }

    if (deal.dealScore >= 70) {
      return 'GOOD';
    }

    if (deal.dealScore >= 50) {
      return 'MARGINAL';
    }

    return 'WEAK';
  }

  String _calculateHistoricalSupport(
    HistoricalPricePosition historical,
  ) {
    if (historical.confidenceLabel ==
        'LOW') {
      return 'LIMITED';
    }

    if (historical.entryTimingLabel ==
            'FAVORABLE' &&
        historical.riskLabel !=
            'HIGH') {
      return 'SUPPORTIVE';
    }

    if (historical.entryTimingLabel ==
            'WAIT FOR PULLBACK' ||
        historical.entryTimingLabel ==
            'WAIT' ||
        historical.riskLabel ==
            'HIGH') {
      return 'UNFAVORABLE';
    }

    return 'NEUTRAL';
  }

  String _calculateVerdictLabel({
  required DealIntelligence deal,
  required HistoricalPricePosition historical,
  ComparableIntelligence? comparable,
}) {
    if (deal.purchasePrice <= 0) {
      return 'ENTER BUY PRICE';
    }

    if (historical.confidenceLabel ==
            'LOW' &&
        deal.dealScore >= 70) {
      return 'PROMISING — LIMITED HISTORY';
    }

    if (deal.dealScore >= 85 &&
    historical.entryTimingLabel ==
    'FAVORABLE' &&
    historical.riskLabel !=
        'HIGH' &&
    (comparable == null ||
        (comparable.evidenceStrength != 'Limited' &&
            comparable.consistency != 'Wide'))) {
  return 'STRONG BUY';
}

    if (deal.dealScore >= 70 &&
        historical.entryTimingLabel !=
            'WAIT FOR PULLBACK' &&
        historical.entryTimingLabel !=
            'WAIT' &&
        historical.riskLabel !=
            'HIGH') {
      return 'BUY';
    }

    if (deal.dealScore >= 70 &&
        (historical.entryTimingLabel ==
                'WAIT FOR PULLBACK' ||
            historical.entryTimingLabel ==
                'WAIT' ||
            historical.riskLabel ==
                'HIGH')) {
      return 'PROCEED WITH CAUTION';
    }

    if (deal.roiPercent > 0 &&
        deal.dealScore < 70) {
      return 'MARGINS TOO THIN';
    }

    return 'PASS';
  }

  String _calculateVerdictMessage({
  required String verdictLabel,
  required DealIntelligence deal,
  required HistoricalPricePosition historical,
  ComparableIntelligence? comparable,
}) {
  final acquisitionCost =
      deal.trueAcquisitionCost;

  final netSaleProceeds =
      deal.marketValue -
      deal.estimatedFees -
      deal.estimatedShipping;

  final profitText =
      '\$${deal.estimatedProfit.toStringAsFixed(2)}';

  final roiText =
      '${deal.roiPercent.toStringAsFixed(1)}%';

  final acquisitionText =
      '\$${acquisitionCost.toStringAsFixed(2)}';

  final proceedsText =
      '\$${netSaleProceeds.toStringAsFixed(2)}';

  switch (verdictLabel) {
    case 'ENTER BUY PRICE':
      return 'Enter a purchase price to generate a unified resale verdict.';

    case 'PROMISING — LIMITED HISTORY':
      return 'The deal projects $profitText profit at $roiText ROI from a '
          '$acquisitionText acquisition cost, but historical pricing evidence '
          'is still limited.';

    case 'STRONG BUY':
      return 'The deal projects $profitText profit at $roiText ROI from a '
          '$acquisitionText acquisition cost, with $proceedsText in estimated '
          'net sale proceeds and favorable historical support.';

    case 'BUY':
  if (comparable != null &&
      (comparable.evidenceStrength == 'Limited' ||
          comparable.consistency == 'Wide')) {
    return 'The deal projects $profitText profit at $roiText ROI from a '
        '$acquisitionText acquisition cost, but comparable pricing evidence '
        'is limited or widely dispersed. Verify the underlying comps before '
        'committing to the purchase.';
  }

  return 'The deal projects $profitText profit at $roiText ROI from a '
      '$acquisitionText acquisition cost, and historical pricing does not '
      'show a major warning.';
    case 'PROCEED WITH CAUTION':
  if (historical.pricePhaseLabel == 'DECLINING' &&
      historical.momentumLabel == 'DOWNWARD') {
    return 'The deal projects $profitText profit at $roiText ROI, but '
        'historical pricing is currently declining with downward momentum. '
        'Waiting for pricing to stabilize may reduce entry risk.';
  }

  if (historical.entryTimingLabel == 'WAIT FOR PULLBACK') {
    return 'The deal projects $profitText profit at $roiText ROI, but '
        'the current market price is near the upper end of its historical '
        'range. Waiting for a lower entry may improve the setup.';
  }

  if (historical.riskLabel == 'HIGH') {
    return 'The deal projects $profitText profit at $roiText ROI, but '
        'historical pricing currently shows high observed risk. The strong '
        'deal economics should be weighed against that pricing uncertainty.';
  }

  return 'The deal projects $profitText profit at $roiText ROI, but '
      'historical pricing currently shows an unfavorable entry condition.';

    case 'MARGINS TOO THIN':
      return 'The deal projects only $profitText profit at $roiText ROI after '
          'a $acquisitionText acquisition cost and selling expenses, leaving '
          'too little margin for a confident resale entry.';

    case 'PASS':
    default:
      return 'After a $acquisitionText acquisition cost and selling expenses, '
          'the deal projects $profitText profit at $roiText ROI. The current '
          'economics and historical pricing do not support a strong resale '
          'opportunity.';
  }
}
}