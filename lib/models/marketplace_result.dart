// ======================================================
// MARKETPLACE ACCESS TYPE
// ======================================================

enum MarketplaceAccessType {
  liveData,
  outboundSearch,
  unavailable,
}

// ======================================================
// UNIFIED MARKETPLACE RESULT
// ======================================================

class MarketplaceResult {
  final String marketplaceName;
  final MarketplaceAccessType accessType;

  final String title;
  final String url;
  final String imageUrl;
  final String availability;
  final String message;

  final double? marketValue;
  final double? lowestPrice;
  final double? averagePrice;
  final double? medianPrice;
  final double? highestPrice;
  final double? priceSpread;

  final int listingCount;
  final List<dynamic> rawItems;

  const MarketplaceResult({
    required this.marketplaceName,
    required this.accessType,
    this.title = '',
    this.url = '',
    this.imageUrl = '',
    this.availability = '',
    this.message = '',
    this.marketValue,
    this.lowestPrice,
    this.averagePrice,
    this.medianPrice,
    this.highestPrice,
    this.priceSpread,
    this.listingCount = 0,
    this.rawItems = const [],
  });

  bool get hasLivePricing {
    return accessType ==
            MarketplaceAccessType.liveData &&
        marketValue != null;
  }

  bool get canOpenMarketplace {
    return url.isNotEmpty;
  }
}