import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// CHRONO24 MARKETPLACE SERVICE
// ======================================================

class Chrono24MarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName => 'Chrono24';

  @override
  MarketplaceAccessType get accessType =>
      MarketplaceAccessType.outboundSearch;

  @override
  Future<MarketplaceResult> searchByQuery(
    String query,
  ) async {
    final cleanedQuery =
        MarketplaceQueryCleaner.clean(query);

    if (cleanedQuery.isEmpty) {
      return const MarketplaceResult(
        marketplaceName: 'Chrono24',
        accessType:
            MarketplaceAccessType.unavailable,
        message: 'A search term is required.',
      );
    }

    final encodedQuery =
        Uri.encodeQueryComponent(
      cleanedQuery,
    );

    return MarketplaceResult(
      marketplaceName: marketplaceName,
      accessType: accessType,
      title: cleanedQuery,
      url:
          'https://www.chrono24.com/search/index.htm?query=$encodedQuery',
      availability:
          'Open Chrono24 to view current luxury watch listings.',
      message:
          'Chrono24 specializes in Rolex, Omega, Patek Philippe, Audemars Piguet, Breitling, TAG Heuer, Tudor, and other luxury timepieces.',
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
        marketplaceName: 'Chrono24',
        accessType:
            MarketplaceAccessType.unavailable,
        message: 'A barcode is required.',
      );
    }

    final encodedBarcode =
        Uri.encodeQueryComponent(
      trimmedBarcode,
    );

    return MarketplaceResult(
      marketplaceName: marketplaceName,
      accessType: accessType,
      title: trimmedBarcode,
      url:
          'https://www.chrono24.com/search/index.htm?query=$encodedBarcode',
      availability:
          'Open Chrono24 to view possible watch matches.',
      message:
          'Chrono24 searches are generally most effective using watch model names or reference numbers.',
    );
  }
}