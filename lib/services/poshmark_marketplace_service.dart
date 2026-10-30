import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// POSHMARK MARKETPLACE SERVICE
// ======================================================

class PoshmarkMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName => 'Poshmark';

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
        marketplaceName: 'Poshmark',
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
          'https://poshmark.com/search?query=$encodedQuery&type=listings&src=dir',
      availability:
          'Open Poshmark to view current listings and pricing.',
      message:
          'Poshmark is currently available through an outbound search.',
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
        marketplaceName: 'Poshmark',
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
          'https://poshmark.com/search?query=$encodedBarcode&type=listings&src=dir',
      availability:
          'Open Poshmark to view possible barcode matches.',
      message:
          'Poshmark barcode lookup currently uses an outbound search.',
    );
  }
}