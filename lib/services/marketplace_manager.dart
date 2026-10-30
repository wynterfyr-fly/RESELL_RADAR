import '../models/marketplace_result.dart';
import 'marketplace_service.dart';

// ======================================================
// MARKETPLACE MANAGER
// ======================================================

class MarketplaceManager {
  final List<MarketplaceService>
      services;

  const MarketplaceManager({
    required this.services,
  });

  Future<List<MarketplaceResult>>
      searchAllByQuery(
    String query,
  ) async {
    final trimmedQuery =
        query.trim();

    if (trimmedQuery.isEmpty) {
      return const [];
    }

    final results =
        await Future.wait(
      services.map(
        (service) async {
          try {
            return await service
                .searchByQuery(
              trimmedQuery,
            );
          } catch (e) {
            return MarketplaceResult(
              marketplaceName:
                  service.marketplaceName,
              accessType:
                  MarketplaceAccessType
                      .unavailable,
              message:
                  '${service.marketplaceName} '
                  'search failed: $e',
            );
          }
        },
      ),
    );

    return results;
  }

  Future<List<MarketplaceResult>>
      lookupAllByBarcode(
    String barcode,
  ) async {
    final trimmedBarcode =
        barcode.trim();

    if (trimmedBarcode.isEmpty) {
      return const [];
    }

    final results =
        await Future.wait(
      services.map(
        (service) async {
          try {
            return await service
                .lookupByBarcode(
              trimmedBarcode,
            );
          } catch (e) {
            return MarketplaceResult(
              marketplaceName:
                  service.marketplaceName,
              accessType:
                  MarketplaceAccessType
                      .unavailable,
              message:
                  '${service.marketplaceName} '
                  'barcode lookup failed: $e',
            );
          }
        },
      ),
    );

    return results;
  }
}