import 'dart:math' as math;
import '../models/price_snapshot.dart';

class HistoricalPricePosition {
  final double latestValue;
  final double historicalLow;
  final double historicalHigh;
  final double positionPercent;
  final String label;
  final String actionLabel;
  final String actionMessage;
  final String confidenceLabel;
  final String confidenceMessage;
  final String opportunityLabel;
  final String opportunityMessage;
  final double historicalAverage;
  final double differenceFromAverage;
  final double percentFromAverage;
  final double volatilityPercent;
  final String volatilityLabel;
  final String riskLabel;
  final String riskMessage;
  final String verdictLabel;
  final String verdictMessage;
  final double priceCushionPercent;
  final String priceCushionLabel;
  final String buyZoneLabel;
  final String buyZoneMessage;
  final double momentumPercent;
  final String momentumLabel;
  final String momentumMessage;
  final double trajectoryPercent;
  final String trajectoryLabel;
  final String trajectoryMessage;
  final String pricePhaseLabel;
  final String pricePhaseMessage;
  final String entryTimingLabel;
  final String entryTimingMessage;

  const HistoricalPricePosition({
    required this.latestValue,
    required this.historicalLow,
    required this.historicalHigh,
    required this.positionPercent,
    required this.label,
    required this.actionLabel,
    required this.actionMessage,
    required this.confidenceLabel,
    required this.confidenceMessage,
    required this.opportunityLabel,
    required this.opportunityMessage,
    required this.historicalAverage,
    required this.differenceFromAverage,
    required this.percentFromAverage,
    required this.volatilityPercent,
    required this.volatilityLabel,
    required this.riskLabel,
    required this.riskMessage,
    required this.verdictLabel,
    required this.verdictMessage,
    required this.priceCushionPercent,
    required this.priceCushionLabel,
    required this.buyZoneLabel,
    required this.buyZoneMessage,
    required this.momentumPercent,
    required this.momentumLabel,
    required this.momentumMessage,
    required this.trajectoryPercent,
    required this.trajectoryLabel,
    required this.trajectoryMessage,
    required this.pricePhaseLabel,
    required this.pricePhaseMessage,
    required this.entryTimingLabel,
    required this.entryTimingMessage,
  });
}

class HistoricalIntelligenceService {
  HistoricalPricePosition? calculatePricePosition(
    List<PriceSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) {
      return null;
    }

    final latestValue = snapshots.first.marketValue;

    double historicalLow = snapshots.first.marketValue;
    double historicalHigh = snapshots.first.marketValue;

    for (final snapshot in snapshots) {
      if (snapshot.marketValue < historicalLow) {
        historicalLow = snapshot.marketValue;
      }

      if (snapshot.marketValue > historicalHigh) {
        historicalHigh = snapshot.marketValue;
      }
    }

    final range = historicalHigh - historicalLow;

    final double positionPercent;

    if (range == 0) {
      positionPercent = 50.0;
    } else {
      positionPercent =
          ((latestValue - historicalLow) / range * 100).clamp(0.0, 100.0);
    }

    final String label;

    if (range == 0) {
      label = 'Stable Historical Range';
    } else if (positionPercent <= 25) {
      label = 'Near Historical Low';
    } else if (positionPercent >= 75) {
      label = 'Near Historical High';
    } else {
      label = 'Mid Historical Range';
    }

final String actionLabel;
final String actionMessage;
final String confidenceLabel;
final String confidenceMessage;
final String opportunityLabel;
final String opportunityMessage;

if (range == 0) {
  actionLabel = 'NEUTRAL';
  actionMessage =
      'Price history is flat, so there is no historical price advantage yet.';
} else if (positionPercent <= 25) {
  actionLabel = 'BUYING WINDOW';
  actionMessage =
      'Current market value is near its observed historical low.';
} else if (positionPercent >= 75) {
  actionLabel = 'CAUTION';
  actionMessage =
      'Current market value is near its observed historical high.';
} else {
  actionLabel = 'WATCH';
  actionMessage =
      'Current market value is trading near the middle of its observed range.';
}
if (snapshots.length >= 6) {
  confidenceLabel = 'HIGH';
  confidenceMessage =
      'Based on ${snapshots.length} stored historical observations.';
} else if (snapshots.length >= 3) {
  confidenceLabel = 'MODERATE';
  confidenceMessage =
      'Based on ${snapshots.length} stored historical observations.';
} else {
  confidenceLabel = 'LOW';
  confidenceMessage =
      'Only ${snapshots.length} historical '
      '${snapshots.length == 1 ? 'observation is' : 'observations are'} '
      'available so far.';
}
final historicalTotal = snapshots.fold<double>(
  0.0,
  (sum, snapshot) => sum + snapshot.marketValue,
);

final historicalAverage =
    historicalTotal / snapshots.length;

final differenceFromAverage =
    latestValue - historicalAverage;

final percentFromAverage =
    historicalAverage == 0
        ? 0.0
        : (differenceFromAverage /
                historicalAverage) *
            100;

final squaredDifferences =
    snapshots.fold<double>(
  0.0,
  (sum, snapshot) {
    final difference =
        snapshot.marketValue -
        historicalAverage;

    return sum +
        (difference * difference);
  },
);

final variance =
    squaredDifferences /
    snapshots.length;

final standardDeviation =
    math.sqrt(variance);
final volatilityPercent =
    historicalAverage == 0
        ? 0.0
        : (standardDeviation /
                historicalAverage) *
            100;

final String volatilityLabel;

if (volatilityPercent < 5) {
  volatilityLabel = 'LOW';
} else if (volatilityPercent < 15) {
  volatilityLabel = 'MODERATE';
} else {
  volatilityLabel = 'HIGH';
}

final String riskLabel;
final String riskMessage;

if (volatilityLabel == 'HIGH' &&
    positionPercent >= 75) {
  riskLabel = 'HIGH';
  riskMessage =
      'Historical prices have been volatile and the current value is near the high end of its observed range.';
} else if (volatilityLabel == 'HIGH') {
  riskLabel = 'HIGH';
  riskMessage =
      'Historical prices have shown substantial variation, increasing pricing risk.';
} else if (volatilityLabel == 'MODERATE' ||
    positionPercent >= 75) {
  riskLabel = 'MODERATE';
  riskMessage =
      'Historical pricing shows some risk from price movement or the current position within its observed range.';
} else {
  riskLabel = 'LOW';
  riskMessage =
      'Historical pricing has remained relatively stable with limited observed pricing risk.';
}

if (actionLabel == 'BUYING WINDOW' &&
    confidenceLabel == 'HIGH') {
  opportunityLabel = 'STRONG';
  opportunityMessage =
      'Current pricing is near its historical low with strong historical support.';
} else if (actionLabel == 'BUYING WINDOW') {
  opportunityLabel = 'POTENTIAL';
  opportunityMessage =
      'Current pricing is near its historical low, but more history would strengthen the signal.';
} else if (actionLabel == 'CAUTION') {
  opportunityLabel = 'WEAK';
  opportunityMessage =
      'Current pricing is near its historical high and offers limited historical buying advantage.';
} else {
  opportunityLabel = 'NEUTRAL';
  opportunityMessage =
      'Current pricing does not show a historical buying advantage.';
}

final String verdictLabel;
final String verdictMessage;

if (opportunityLabel == 'STRONG' &&
    confidenceLabel == 'HIGH' &&
    riskLabel == 'LOW') {
  verdictLabel = 'FAVORABLE';
  verdictMessage =
      'Historical pricing supports a favorable buying setup with strong evidence and limited observed risk.';
} else if ((opportunityLabel == 'STRONG' ||
        opportunityLabel == 'POTENTIAL') &&
    riskLabel != 'HIGH') {
  verdictLabel = 'PROMISING';
  verdictMessage =
      'Historical pricing shows potential, but the opportunity should still be weighed against the available evidence and risk.';
} else if (riskLabel == 'HIGH' ||
    opportunityLabel == 'WEAK') {
  verdictLabel = 'CAUTION';
  verdictMessage =
      'Historical pricing suggests elevated risk or an unfavorable current price position.';
} else if (confidenceLabel == 'LOW') {
  verdictLabel = 'WAIT';
  verdictMessage =
      'More historical observations are needed before relying heavily on the current pricing signal.';
} else {
  verdictLabel = 'NEUTRAL';
  verdictMessage =
      'Historical pricing is stable, but the current price does not offer a clear buying advantage.';
}

final double priceCushionPercent =
    historicalHigh > 0
        ? ((historicalHigh - latestValue) / historicalHigh) * 100
        : 0.0;

final String priceCushionLabel;

if (priceCushionPercent >= 20) {
  priceCushionLabel = 'STRONG';
} else if (priceCushionPercent >= 10) {
  priceCushionLabel = 'MODERATE';
} else if (priceCushionPercent > 0) {
  priceCushionLabel = 'LIMITED';
} else {
  priceCushionLabel = 'NONE';
}

final String buyZoneLabel;
final String buyZoneMessage;

if (confidenceLabel == 'LOW') {
  buyZoneLabel = 'EARLY DATA';
  buyZoneMessage =
      'More historical observations are needed before defining a reliable buying zone.';
} else if (positionPercent <= 25 &&
    riskLabel != 'HIGH') {
  buyZoneLabel = 'BUY ZONE';
  buyZoneMessage =
      'Current pricing is near the lower end of its observed historical range.';
} else if (positionPercent >= 75) {
  buyZoneLabel = 'EXPENSIVE ZONE';
  buyZoneMessage =
      'Current pricing is near the upper end of its observed historical range.';
} else {
  buyZoneLabel = 'FAIR VALUE ZONE';
  buyZoneMessage =
      'Current pricing is sitting within its established historical range.';
}

final recentSnapshots =
    snapshots.take(3).toList();

final double momentumPercent;
final String momentumLabel;
final String momentumMessage;

if (recentSnapshots.length < 2) {
  momentumPercent = 0.0;
  momentumLabel = 'EARLY DATA';
  momentumMessage =
      'More observations are needed to evaluate recent price momentum.';
} else {
  final recentLatest =
      recentSnapshots.first.marketValue;

  final recentOldest =
      recentSnapshots.last.marketValue;

  momentumPercent =
      recentOldest == 0
          ? 0.0
          : ((recentLatest - recentOldest) /
                  recentOldest) *
              100;

  if (momentumPercent >= 5) {
    momentumLabel = 'STRONG UPWARD';
    momentumMessage =
        'Recent historical observations show strong upward price momentum.';
  } else if (momentumPercent >= 1) {
    momentumLabel = 'UPWARD';
    momentumMessage =
        'Recent historical observations show upward price momentum.';
  } else if (momentumPercent <= -5) {
    momentumLabel = 'STRONG DOWNWARD';
    momentumMessage =
        'Recent historical observations show strong downward price momentum.';
  } else if (momentumPercent <= -1) {
    momentumLabel = 'DOWNWARD';
    momentumMessage =
        'Recent historical observations show downward price momentum.';
  } else {
    momentumLabel = 'FLAT';
    momentumMessage =
        'Recent historical observations show little meaningful price momentum.';
  }
}

final double trajectoryPercent;
final String trajectoryLabel;
final String trajectoryMessage;

if (snapshots.length < 2) {
  trajectoryPercent = 0.0;
  trajectoryLabel = 'EARLY DATA';
  trajectoryMessage =
      'More observations are needed to evaluate the broader historical trajectory.';
} else {
  final trajectoryLatest =
      snapshots.first.marketValue;

  final trajectoryOldest =
      snapshots.last.marketValue;

  trajectoryPercent =
      trajectoryOldest == 0
          ? 0.0
          : ((trajectoryLatest - trajectoryOldest) /
                  trajectoryOldest) *
              100;

  if (trajectoryPercent >= 10) {
    trajectoryLabel = 'STRONG UPWARD';
    trajectoryMessage =
        'The broader historical record shows substantial upward price movement.';
  } else if (trajectoryPercent >= 1) {
    trajectoryLabel = 'UPWARD';
    trajectoryMessage =
        'The broader historical record shows upward price movement.';
  } else if (trajectoryPercent <= -10) {
    trajectoryLabel = 'STRONG DOWNWARD';
    trajectoryMessage =
        'The broader historical record shows substantial downward price movement.';
  } else if (trajectoryPercent <= -1) {
    trajectoryLabel = 'DOWNWARD';
    trajectoryMessage =
        'The broader historical record shows downward price movement.';
  } else {
    trajectoryLabel = 'FLAT';
    trajectoryMessage =
        'The broader historical record shows little meaningful directional movement.';
  }
}

final String pricePhaseLabel;
final String pricePhaseMessage;

if (trajectoryLabel == 'EARLY DATA' ||
    momentumLabel == 'EARLY DATA') {
  pricePhaseLabel = 'EARLY DATA';
  pricePhaseMessage =
      'More historical observations are needed to identify a reliable price phase.';
} else if ((trajectoryLabel == 'UPWARD' ||
        trajectoryLabel == 'STRONG UPWARD') &&
    (momentumLabel == 'UPWARD' ||
        momentumLabel == 'STRONG UPWARD')) {
  pricePhaseLabel = 'ADVANCING';
  pricePhaseMessage =
      'The broader price trend and recent momentum are both moving upward.';
} else if ((trajectoryLabel == 'UPWARD' ||
        trajectoryLabel == 'STRONG UPWARD') &&
    momentumLabel == 'FLAT') {
  pricePhaseLabel = 'PLATEAUING';
  pricePhaseMessage =
      'The broader price trend is upward, but recent momentum has flattened.';
} else if ((trajectoryLabel == 'UPWARD' ||
        trajectoryLabel == 'STRONG UPWARD') &&
    (momentumLabel == 'DOWNWARD' ||
        momentumLabel == 'STRONG DOWNWARD')) {
  pricePhaseLabel = 'REVERSING';
  pricePhaseMessage =
      'The broader price trend remains upward, but recent momentum has turned downward.';
} else if ((trajectoryLabel == 'DOWNWARD' ||
        trajectoryLabel == 'STRONG DOWNWARD') &&
    (momentumLabel == 'DOWNWARD' ||
        momentumLabel == 'STRONG DOWNWARD')) {
  pricePhaseLabel = 'DECLINING';
  pricePhaseMessage =
      'The broader price trend and recent momentum are both moving downward.';
} else if ((trajectoryLabel == 'DOWNWARD' ||
        trajectoryLabel == 'STRONG DOWNWARD') &&
    momentumLabel == 'FLAT') {
  pricePhaseLabel = 'STABILIZING';
  pricePhaseMessage =
      'The broader price trend is downward, but recent momentum has flattened.';
} else if ((trajectoryLabel == 'DOWNWARD' ||
        trajectoryLabel == 'STRONG DOWNWARD') &&
    (momentumLabel == 'UPWARD' ||
        momentumLabel == 'STRONG UPWARD')) {
  pricePhaseLabel = 'RECOVERING';
  pricePhaseMessage =
      'The broader price trend is downward, but recent momentum has turned upward.';
} else {
  pricePhaseLabel = 'STABLE';
  pricePhaseMessage =
      'Historical pricing currently shows no meaningful directional phase.';
}

final String entryTimingLabel;
final String entryTimingMessage;

if (confidenceLabel == 'LOW') {
  entryTimingLabel = 'EARLY DATA';
  entryTimingMessage =
      'More historical observations are needed before judging entry timing.';
} else if (buyZoneLabel == 'BUY ZONE' &&
    riskLabel != 'HIGH' &&
    pricePhaseLabel != 'DECLINING') {
  entryTimingLabel = 'FAVORABLE';
  entryTimingMessage =
      'Historical pricing currently supports a potentially favorable entry window.';
} else if (buyZoneLabel == 'EXPENSIVE ZONE') {
  entryTimingLabel = 'WAIT FOR PULLBACK';
  entryTimingMessage =
      'Current pricing is near the upper end of its historical range, so waiting for a lower entry may improve the setup.';
} else if (pricePhaseLabel == 'DECLINING' ||
    pricePhaseLabel == 'REVERSING') {
  entryTimingLabel = 'WAIT';
  entryTimingMessage =
      'Recent historical behavior suggests waiting for pricing to stabilize before entering.';
} else {
  entryTimingLabel = 'WATCH';
  entryTimingMessage =
      'Historical pricing does not currently show a strong entry advantage or a major warning.';
}

    return HistoricalPricePosition(
  latestValue: latestValue,
  historicalLow: historicalLow,
  historicalHigh: historicalHigh,
  positionPercent: positionPercent,
  label: label,
  actionLabel: actionLabel,
  actionMessage: actionMessage,
  confidenceLabel: confidenceLabel,
  confidenceMessage: confidenceMessage,
  opportunityLabel: opportunityLabel,
  opportunityMessage: opportunityMessage,
  historicalAverage: historicalAverage,
  differenceFromAverage: differenceFromAverage,
  percentFromAverage: percentFromAverage,
  volatilityPercent: volatilityPercent,
  volatilityLabel: volatilityLabel,
  riskLabel: riskLabel,
  riskMessage: riskMessage,
  verdictLabel: verdictLabel,
  verdictMessage: verdictMessage,
  priceCushionPercent: priceCushionPercent,
  priceCushionLabel: priceCushionLabel,
  buyZoneLabel: buyZoneLabel,
  buyZoneMessage: buyZoneMessage,
  momentumPercent: momentumPercent,
  momentumLabel: momentumLabel,
  momentumMessage: momentumMessage,
  trajectoryPercent: trajectoryPercent,
  trajectoryLabel: trajectoryLabel,
  trajectoryMessage: trajectoryMessage,
  pricePhaseLabel: pricePhaseLabel,
  pricePhaseMessage: pricePhaseMessage,
  entryTimingLabel: entryTimingLabel,
  entryTimingMessage: entryTimingMessage,
);
  }
}