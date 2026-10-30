// ======================================================
// MARKETPLACE SEARCH QUERY CLEANER
// ======================================================
//
// Converts long marketplace listing titles into shorter,
// cleaner search phrases for outbound marketplace links.
//
// Example:
//
// "(2) Handmade 100% Pure Beeswax Candle 100% Cotton Wick"
//
// becomes:
//
// "Handmade Pure Beeswax Candle Cotton Wick"

class MarketplaceQueryCleaner {
  const MarketplaceQueryCleaner._();

  static String clean(
    String rawQuery, {
    int maxWords = 8,
  }) {
    final trimmedQuery = rawQuery.trim();

    if (trimmedQuery.isEmpty) {
      return '';
    }

    var cleanedQuery = trimmedQuery;

    // Remove quantity markers at the beginning:
    // (2), [2], 2 pack, 2-pack, pack of 2, set of 2.
    cleanedQuery = cleanedQuery.replaceFirst(
      RegExp(
        r'^\s*[\(\[]\s*\d+\s*[\)\]]\s*',
        caseSensitive: false,
      ),
      '',
    );

    cleanedQuery = cleanedQuery.replaceFirst(
      RegExp(
        r'^\s*(?:pack|set)\s+of\s+\d+\s*',
        caseSensitive: false,
      ),
      '',
    );

    cleanedQuery = cleanedQuery.replaceFirst(
      RegExp(
        r'^\s*\d+\s*[- ]?(?:pack|count|ct)\b\s*',
        caseSensitive: false,
      ),
      '',
    );

    // Remove percentages such as 100% or 50%.
    cleanedQuery = cleanedQuery.replaceAll(
      RegExp(
        r'\b\d+(?:\.\d+)?\s*%',
        caseSensitive: false,
      ),
      ' ',
    );

    // Replace symbols and punctuation with spaces while
    // preserving letters, numbers, apostrophes, and hyphens.
    cleanedQuery = cleanedQuery.replaceAll(
      RegExp(
        r"[^a-zA-Z0-9'\-\s]",
      ),
      ' ',
    );

    // Normalize repeated spaces.
    cleanedQuery = cleanedQuery.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    final words = cleanedQuery
        .trim()
        .split(' ')
        .where(
          (word) => word.isNotEmpty,
        )
        .toList();

    final uniqueWords = <String>[];
    final seenWords = <String>{};

    for (final word in words) {
      final normalizedWord =
          word.toLowerCase();

      // Remove exact duplicate words while keeping
      // the first occurrence and original capitalization.
      if (seenWords.add(normalizedWord)) {
        uniqueWords.add(word);
      }

      if (uniqueWords.length >= maxWords) {
        break;
      }
    }

    return uniqueWords.join(' ').trim();
  }
}