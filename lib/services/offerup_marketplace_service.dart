import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// OFFERUP MARKETPLACE SERVICE
// ======================================================

class OfferUpMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName => 'OfferUp';

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
        marketplaceName: 'OfferUp',
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
          'https://offerup.com/search?q=$encodedQuery',
      availability:
          'Open OfferUp to view current local listings.',
      message:
          'OfferUp is currently available through an outbound search.',
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
        marketplaceName: 'OfferUp',
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
          'https://offerup.com/search?q=$encodedBarcode',
      availability:
          'Open OfferUp to view possible barcode matches.',
      message:
          'OfferUp barcode lookup currently uses an outbound search.',
    );
  }
}