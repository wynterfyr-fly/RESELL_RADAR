import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/marketplace_result.dart';
import 'marketplace_service.dart';

// ======================================================
// EBAY MARKETPLACE SERVICE
// ======================================================

class EbayMarketplaceService
    implements MarketplaceService {
  final String baseUrl;

  const EbayMarketplaceService({
    required this.baseUrl,
  });

  @override
  String get marketplaceName =>
      'eBay';

  @override
  MarketplaceAccessType get accessType =>
      MarketplaceAccessType.liveData;

  @override
  Future<MarketplaceResult> searchByQuery(
    String query,
  ) async {
    final trimmedQuery =
        query.trim();

    if (trimmedQuery.isEmpty) {
      return const MarketplaceResult(
        marketplaceName: 'eBay',
        accessType:
            MarketplaceAccessType.liveData,
        message:
            'Enter a product name to search eBay.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/ebay-search/'
          '${Uri.encodeComponent(trimmedQuery)}',
        ),
      );

      final data =
          jsonDecode(response.body);

      if (data['success'] != true) {
        return const MarketplaceResult(
          marketplaceName: 'eBay',
          accessType:
              MarketplaceAccessType.liveData,
          message:
              'No eBay products were found.',
        );
      }

      final products =
          data['products'] as List<dynamic>? ??
              const [];

      if (products.isEmpty) {
        return const MarketplaceResult(
          marketplaceName: 'eBay',
          accessType:
              MarketplaceAccessType.liveData,
          message:
              'No eBay products were found.',
        );
      }

      final firstProduct =
          products.first
              as Map<String, dynamic>;

      return MarketplaceResult(
        marketplaceName: 'eBay',
        accessType:
            MarketplaceAccessType.liveData,
        title:
            firstProduct['name']
                    ?.toString() ??
                'eBay Result',
        url:
            firstProduct['marketplaceUrl']
                    ?.toString() ??
                'https://www.ebay.com',
        imageUrl:
            firstProduct['image']
                    ?.toString() ??
                '',
        marketValue:
            (firstProduct['marketPrice']
                    as num?)
                ?.toDouble(),
        lowestPrice:
            (firstProduct['lowestPrice']
                    as num?)
                ?.toDouble(),
        averagePrice:
            (firstProduct['averagePrice']
                    as num?)
                ?.toDouble(),
        medianPrice:
            (firstProduct['medianPrice']
                    as num?)
                ?.toDouble(),
        highestPrice:
            (firstProduct['highestPrice']
                    as num?)
                ?.toDouble(),
        priceSpread:
            (firstProduct['priceSpread']
                    as num?)
                ?.toDouble(),
        listingCount:
            (firstProduct['resultCount']
                    as num?)
                ?.toInt() ??
            0,
        message:
            'Live eBay pricing data.',
      );
    } catch (e) {
      return MarketplaceResult(
        marketplaceName: 'eBay',
        accessType:
            MarketplaceAccessType.liveData,
        message:
            'eBay search failed: $e',
      );
    }
  }

  @override
  Future<MarketplaceResult> lookupByBarcode(
    String barcode,
  ) async {
    final trimmedBarcode =
        barcode.trim();

    if (trimmedBarcode.isEmpty) {
      return const MarketplaceResult(
        marketplaceName: 'eBay',
        accessType:
            MarketplaceAccessType.liveData,
        message:
            'Enter a barcode to search eBay.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/ebay-lookup/'
          '${Uri.encodeComponent(trimmedBarcode)}',
        ),
      );

      final data =
          jsonDecode(response.body);

      if (data['success'] != true) {
        return const MarketplaceResult(
          marketplaceName: 'eBay',
          accessType:
              MarketplaceAccessType.liveData,
          message:
              'No eBay product was found.',
        );
      }

      final product =
          data['product']
              as Map<String, dynamic>;

      return MarketplaceResult(
        marketplaceName: 'eBay',
        accessType:
            MarketplaceAccessType.liveData,
        title:
            product['name']
                    ?.toString() ??
                'eBay Result',
        url:
            product['marketplaceUrl']
                    ?.toString() ??
                'https://www.ebay.com',
        imageUrl:
            product['image']
                    ?.toString() ??
                '',
        marketValue:
            (product['marketPrice']
                    as num?)
                ?.toDouble(),
        lowestPrice:
            (product['lowestPrice']
                    as num?)
                ?.toDouble(),
        averagePrice:
            (product['averagePrice']
                    as num?)
                ?.toDouble(),
        medianPrice:
            (product['medianPrice']
                    as num?)
                ?.toDouble(),
        highestPrice:
            (product['highestPrice']
                    as num?)
                ?.toDouble(),
        priceSpread:
            (product['priceSpread']
                    as num?)
                ?.toDouble(),
        listingCount:
            (product['resultCount']
                    as num?)
                ?.toInt() ??
            0,
        rawItems:
            data['rawItems'] ??
                product['rawItems'] ??
                const [],
        message:
            'Live eBay pricing data.',
      );
    } catch (e) {
      return MarketplaceResult(
        marketplaceName: 'eBay',
        accessType:
            MarketplaceAccessType.liveData,
        message:
            'eBay barcode lookup failed: $e',
      );
    }
  }
}