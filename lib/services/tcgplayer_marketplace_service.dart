import '../models/marketplace_result.dart';
import '../utils/marketplace_query_cleaner.dart';
import 'marketplace_service.dart';

// ======================================================
// TCGPLAYER MARKETPLACE SERVICE
// ======================================================

class TCGplayerMarketplaceService
    implements MarketplaceService {
  @override
  String get marketplaceName => 'TCGplayer';

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
        marketplaceName: 'TCGplayer',
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
          'https://www.tcgplayer.com/search/all/product?q=$encodedQuery&view=grid',
      availability:
          'Open TCGplayer to view current trading card listings.',
      message:
          'TCGplayer specializes in Pokémon, Magic: The Gathering, Yu-Gi-Oh!, sports cards, and other collectibles.',
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
        marketplaceName: 'TCGplayer',
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
          'https://www.tcgplayer.com/search/all/product?q=$encodedBarcode&view=grid',
      availability:
          'Open TCGplayer to view possible barcode matches.',
      message:
          'Barcode searches may return sealed products or trading cards associated with the code.',
    );
  }
}