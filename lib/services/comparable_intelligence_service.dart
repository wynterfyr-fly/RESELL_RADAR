import '../models/comparable_intelligence.dart';

class ComparableIntelligenceService {
  static ComparableIntelligence? analyze({
   required List<dynamic> rawItems,
   required double marketValue,
   required String targetTitle,
}) {
    final normalizedTargetTitle =
    targetTitle.toLowerCase();

final ignoredTargetWords = <String>{
  'the',
  'a',
  'an',
  'and',
  'or',
  'with',
  'for',
  'of',
  'in',
  'on',
  'new',
  'brand',
  'sealed',
};

final targetTokens =
    normalizedTargetTitle
        .split(
          RegExp(r'[^a-z0-9]+'),
        )
        .where(
          (token) =>
              token.length >= 3 &&
              !ignoredTargetWords
                  .contains(token),
        )
        .toSet();

final targetSpecTokens =
    targetTokens
        .where(
          (token) =>
              RegExp(r'[a-z]').hasMatch(token) &&
              RegExp(r'\d').hasMatch(token) &&
              !RegExp(r'^\d+(st|nd|rd|th)$')
                  .hasMatch(token),
        )
        .toSet();

final excludedTitlePatterns = <String>[
  'case only',
  'box only',
  'empty box',
  'parts only',
  'for parts',
];

final targetIsConsole =
    normalizedTargetTitle.contains('console');

final targetIsWhite =
    normalizedTargetTitle.contains('white');

    final targetIsMarioRed =
    normalizedTargetTitle.contains('mario red');

final targetIsEliteTrainerBox =
    normalizedTargetTitle.contains('elite trainer box') ||
    RegExp(r'\betb\b').hasMatch(normalizedTargetTitle);

    final targetHasPackageExtras =
    normalizedTargetTitle.contains('dock') ||
    normalizedTargetTitle.contains('joy-con') ||
    normalizedTargetTitle.contains('joycon') ||
    normalizedTargetTitle.contains('accessories') ||
    normalizedTargetTitle.contains('bundle');

final targetIsConsoleOnly =
    targetIsConsole &&
    !targetHasPackageExtras;

final relevantItems = <dynamic>[];
int excludedComparableCount = 0;

for (final item in rawItems) {
  if (item is! Map) {
    continue;
  }

  final title =
    (item['title'] ?? '')
        .toString()
        .toLowerCase();

final candidateIsEliteTrainerBox =
    title.contains('elite trainer box') ||
    RegExp(r'\betb\b').hasMatch(title);

final excludesEliteTrainerBoxMismatch =
    targetIsEliteTrainerBox &&
    !candidateIsEliteTrainerBox;

final itemTokens =
    title
        .split(
          RegExp(r'[^a-z0-9]+'),
        )
        .where(
          (token) =>
              token.length >= 3 &&
              !ignoredTargetWords
                  .contains(token),
        )
        .toSet();

final itemSpecTokens =
    itemTokens
        .where(
          (token) =>
              RegExp(r'[a-z]').hasMatch(token) &&
              RegExp(r'\d').hasMatch(token) &&
              !RegExp(r'^\d+(st|nd|rd|th)$')
                  .hasMatch(token),
        )
        .toSet();

        final matchingSpecTokenCount =
    targetSpecTokens
        .intersection(itemSpecTokens)
        .length;

final hasTargetAndItemSpecs =
    targetSpecTokens.isNotEmpty &&
    itemSpecTokens.isNotEmpty;

final hasConflictingSpecTokens =
    hasTargetAndItemSpecs &&
    matchingSpecTokenCount == 0;

    final excludesConflictingSpecs =
    hasConflictingSpecTokens &&
    targetSpecTokens.length == 1 &&
    itemSpecTokens.length == 1;

final matchingTargetTokenCount =
    targetTokens
        .intersection(itemTokens)
        .length;

final targetTokenMatchPercent =
    targetTokens.isNotEmpty
        ? matchingTargetTokenCount /
            targetTokens.length
        : 0.0;

final excludesVeryWeakTitleMatch =
    targetTokens.length >= 4 &&
    matchingTargetTokenCount <= 1 &&
    targetTokenMatchPercent < 0.25;

final matchesGlobalExclusion =
    excludedTitlePatterns.any(
  (pattern) =>
      title.contains(pattern),
);

final excludesConsoleFromConsoleTarget =
    targetIsConsole &&
    title.contains(
      'no console included',
    );

final excludesDifferentConsoleVariant =
    targetIsConsole &&
    targetIsWhite &&
    !targetIsMarioRed &&
    title.contains('mario red');

final compHasPackageExtras =
    title.contains('dock') ||
    title.contains('joy-con') ||
    title.contains('joycon') ||
    title.contains('accessories') ||
    title.contains('bundle');

final excludesPackageMismatch =
    targetIsConsoleOnly &&
    compHasPackageExtras;

final shouldExclude =
    matchesGlobalExclusion ||
    excludesConsoleFromConsoleTarget ||
    excludesDifferentConsoleVariant ||
    excludesPackageMismatch ||
    excludesEliteTrainerBoxMismatch ||
    excludesConflictingSpecs ||
    excludesVeryWeakTitleMatch;

if (shouldExclude) {
  excludedComparableCount++;
  continue;
}

  relevantItems.add(item);
}

final prices = <double>[];

for (final item in relevantItems) {
  final rawPrice =
      item['price']?['value'];

  final parsedPrice =
      rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(
              rawPrice?.toString() ?? '',
            );

  if (parsedPrice != null &&
      parsedPrice > 0) {
    prices.add(parsedPrice);
  }
}

    if (prices.isEmpty) {
      return null;
    }

    prices.sort();

    final comparableCount = prices.length;
    final lowPrice = prices.first;
    final highPrice = prices.last;

    final averagePrice =
        prices.reduce((a, b) => a + b) / comparableCount;

    final double medianPrice;

    if (comparableCount.isOdd) {
      medianPrice = prices[comparableCount ~/ 2];
    } else {
      final upper = prices[comparableCount ~/ 2];
      final lower = prices[(comparableCount ~/ 2) - 1];
      medianPrice = (lower + upper) / 2;
    }

    final priceSpread = highPrice - lowPrice;

    final spreadPercent =
        averagePrice > 0 ? (priceSpread / averagePrice) * 100 : 0.0;

    final marketValueDifference = marketValue - averagePrice;

    final marketValueDifferencePercent = averagePrice > 0
        ? (marketValueDifference / averagePrice) * 100
        : 0.0;

    final String consistency;

    if (spreadPercent <= 10) {
      consistency = 'Tight';
    } else if (spreadPercent <= 25) {
      consistency = 'Moderate';
    } else {
      consistency = 'Wide';
    }

final medianDifferencePercent =
    medianPrice > 0
        ? ((marketValue - medianPrice) / medianPrice) * 100
        : 0.0;

final String valuationBasis;

if (consistency == 'Wide') {
  if (medianDifferencePercent.abs() <= 10) {
    valuationBasis = 'Aligned with Comp Median';
  } else if (medianDifferencePercent > 10) {
    valuationBasis = 'Above Comp Median';
  } else {
    valuationBasis = 'Below Comp Median';
  }
} else {
  if (marketValueDifferencePercent.abs() <= 10) {
    valuationBasis = 'Aligned with Comp Average';
  } else if (marketValueDifferencePercent > 10) {
    valuationBasis = 'Above Comp Average';
  } else {
    valuationBasis = 'Below Comp Average';
  }
}

final String evidenceStrength;

if (comparableCount >= 5 && spreadPercent <= 15) {
  evidenceStrength = 'Strong';
} else if (comparableCount >= 3 && spreadPercent <= 30) {
  evidenceStrength = 'Moderate';
} else {
  evidenceStrength = 'Limited';
}

    return ComparableIntelligence(
      comparableCount: comparableCount,
      lowPrice: lowPrice,
      highPrice: highPrice,
      averagePrice: averagePrice,
      medianPrice: medianPrice,
      priceSpread: priceSpread,
      spreadPercent: spreadPercent,
      marketValueDifference: marketValueDifference,
      marketValueDifferencePercent: marketValueDifferencePercent,
      consistency: consistency,
      evidenceStrength: evidenceStrength,
      valuationBasis: valuationBasis,
      relevantComparableCount: comparableCount,
      excludedComparableCount: excludedComparableCount,
      relevanceQuality: excludedComparableCount == 0
    ? 'Strong'
    : excludedComparableCount == 1
        ? 'Moderate'
        : 'Weak',
        relevantItems: relevantItems,
    );
  }
}