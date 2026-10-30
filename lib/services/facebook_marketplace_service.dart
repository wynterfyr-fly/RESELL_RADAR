import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// FACEBOOK MARKETPLACE SERVICE
// ======================================================

class FacebookMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName =>
      'Facebook Marketplace';

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
        marketplaceName:
            'Facebook Marketplace',
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
          'https://www.facebook.com/marketplace/category/search/?query=$encodedQuery',
      availability:
          'Open Facebook Marketplace to view local listings.',
      message:
          'Facebook Marketplace may require you to log in before browsing.',
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
        marketplaceName:
            'Facebook Marketplace',
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
          'https://www.facebook.com/marketplace/category/search/?query=$encodedBarcode',
      availability:
          'Open Facebook Marketplace to view possible barcode matches.',
      message:
          'Facebook Marketplace may require you to log in before browsing.',
    );
  }
}