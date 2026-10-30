import '../models/marketplace_result.dart';

// ======================================================
// MARKETPLACE SERVICE CONTRACT
// ======================================================

abstract class MarketplaceService {
  String get marketplaceName;

  MarketplaceAccessType get accessType;

  Future<MarketplaceResult> searchByQuery(
    String query,
  );

  Future<MarketplaceResult> lookupByBarcode(
    String barcode,
  );
}