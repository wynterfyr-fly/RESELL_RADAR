import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// ETSY MARKETPLACE SERVICE
// ======================================================

class EtsyMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName => 'Etsy';

  @override
  MarketplaceAccessType get accessType =>
      MarketplaceAccessType.outboundSearch;

  @override
  Future<MarketplaceResult> searchByQuery(
    String query,
  ) async {
   final cleanedQuery =
    MarketplaceQueryCleaner.clean(
  query,
);

if (cleanedQuery.isEmpty) {
      return const MarketplaceResult(
        marketplaceName: 'Etsy',
        accessType:
            MarketplaceAccessType.unavailable,
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
          'https://www.etsy.com/search?q=$encodedQuery',
      availability:
          'Open Etsy to view current listings and pricing.',
      message:
          'Etsy is currently available through an outbound search.',
    );
  }

  @override
  Future<MarketplaceResult> lookupByBarcode(
    String barcode,
  ) async {
    final trimmedBarcode =
        barcode.trim();

    if (trimmedBarcode.isEmpty) {
      return const MarketplaceResult(
        marketplaceName: 'Etsy',
        accessType:
            MarketplaceAccessType.unavailable,
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
          'https://www.etsy.com/search?q=$encodedBarcode',
      availability:
          'Open Etsy to view possible barcode matches.',
      message:
          'Etsy barcode lookup currently uses an outbound search.',
    );
  }
}