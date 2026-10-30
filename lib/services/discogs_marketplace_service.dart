import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// DISCOGS MARKETPLACE SERVICE
// ======================================================

class DiscogsMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName => 'Discogs';

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
        marketplaceName: 'Discogs',
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
          'https://www.discogs.com/search?q=$encodedQuery&type=all',
      availability:
          'Open Discogs to view current music marketplace listings.',
      message:
          'Discogs specializes in vinyl records, CDs, cassettes, and other music collectibles.',
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
        marketplaceName: 'Discogs',
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
          'https://www.discogs.com/search?q=$encodedBarcode&type=all',
      availability:
          'Open Discogs to view possible barcode matches.',
      message:
          'Discogs may return releases, artists, labels, or marketplace listings related to the barcode.',
    );
  }
}