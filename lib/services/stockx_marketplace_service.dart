import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// STOCKX MARKETPLACE SERVICE
// ======================================================

class StockxMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName =>
      'StockX';

  @override
  MarketplaceAccessType get accessType =>
      MarketplaceAccessType
          .outboundSearch;

  @override
  Future<MarketplaceResult>
      searchByQuery(
    String query,
  ) async {
    final cleanedQuery =
    MarketplaceQueryCleaner.clean(
  query,
);

if (cleanedQuery.isEmpty) {
      return const MarketplaceResult(
        marketplaceName: 'StockX',
        accessType:
            MarketplaceAccessType
                .unavailable,
        message:
            'A search term is required.',
      );
    }

    final encodedQuery =
    Uri.encodeQueryComponent(
  cleanedQuery,
);

    return MarketplaceResult(
      marketplaceName:
          marketplaceName,
      accessType:
          accessType,
      title:
          cleanedQuery,
      url:
          'https://stockx.com/search?s=$encodedQuery',
      availability:
          'Open StockX to view current products and pricing.',
      message:
          'StockX is currently available through an outbound search.',
    );
  }

  @override
  Future<MarketplaceResult>
      lookupByBarcode(
    String barcode,
  ) async {
    final trimmedBarcode =
        barcode.trim();

    if (trimmedBarcode.isEmpty) {
      return const MarketplaceResult(
        marketplaceName: 'StockX',
        accessType:
            MarketplaceAccessType
                .unavailable,
        message:
            'A barcode is required.',
      );
    }

    final encodedBarcode =
        Uri.encodeQueryComponent(
      trimmedBarcode,
    );

    return MarketplaceResult(
      marketplaceName:
          marketplaceName,
      accessType:
          accessType,
      title:
          trimmedBarcode,
      url:
          'https://stockx.com/search?s=$encodedBarcode',
      availability:
          'Open StockX to view possible barcode matches.',
      message:
          'StockX barcode lookup currently uses an outbound search.',
    );
  }
}