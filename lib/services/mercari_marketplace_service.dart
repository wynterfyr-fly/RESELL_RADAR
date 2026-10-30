import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// MERCARI MARKETPLACE SERVICE
// ======================================================

class MercariMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName =>
      'Mercari';

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
        marketplaceName: 'Mercari',
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
          'https://www.mercari.com/search/?keyword=$encodedQuery',
      availability:
          'Open Mercari to view current listings.',
      message:
          'Mercari pricing is available through an outbound search.',
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
        marketplaceName: 'Mercari',
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
          'https://www.mercari.com/search/?keyword=$encodedBarcode',
      availability:
          'Open Mercari to view matching listings.',
      message:
          'Mercari barcode lookup uses an outbound search.',
    );
  }
}