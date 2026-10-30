import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// GRAILED MARKETPLACE SERVICE
// ======================================================

class GrailedMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName => 'Grailed';

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
        marketplaceName: 'Grailed',
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
          'https://www.grailed.com/shop?query=$encodedQuery',
      availability:
          'Open Grailed to view current listings.',
      message:
          'Grailed is currently available through an outbound search.',
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
        marketplaceName: 'Grailed',
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
          'https://www.grailed.com/shop?query=$encodedBarcode',
      availability:
          'Open Grailed to view possible barcode matches.',
      message:
          'Grailed barcode lookup currently uses an outbound search.',
    );
  }
}