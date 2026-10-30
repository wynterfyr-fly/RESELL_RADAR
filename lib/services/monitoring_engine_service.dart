import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../models/product_monitor.dart';

// ======================================================
// MONITORING CHECK RESULT
// ======================================================

class MonitoringCheckResult {
  final double currentMarketValue;
  final DateTime checkedAt;
  final bool isAvailable;

  const MonitoringCheckResult({
    required this.currentMarketValue,
    required this.checkedAt,
    this.isAvailable = true,
  });
}

// ======================================================
// MONITORING ENGINE SERVICE
// ======================================================

class MonitoringEngineService {
  final String backendBaseUrl;

  const MonitoringEngineService({
    required this.backendBaseUrl,
  });

  Future<MonitoringCheckResult>
      checkMonitor(
    ProductMonitor monitor,
  ) async {
    if (monitor.marketplace !=
    'eBay') {
  throw UnsupportedError(
    'Automatic monitoring currently supports eBay only.',
  );
}

if (monitor.marketplaceItemId.isNotEmpty) {
  return _checkSpecificListing(monitor);
}

final currentMarketValue =
    monitor.barcode.isNotEmpty
        ? await _lookupByBarcode(
            monitor.barcode,
          )
        : await _lookupByTitle(
            monitor.productTitle,
          );

    return MonitoringCheckResult(
      currentMarketValue:
          currentMarketValue,
      checkedAt:
          DateTime.now(),
    );
  }

Future<MonitoringCheckResult>
    _checkSpecificListing(
  ProductMonitor monitor,
) async {
  final response = await http.get(
    Uri.parse(
      '$backendBaseUrl/ebay-item-status/'
      '${Uri.encodeComponent(monitor.marketplaceItemId)}',
    ),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'eBay listing status check failed '
      'with status ${response.statusCode}.',
    );
  }

  final data = jsonDecode(response.body);

  if (data['success'] != true) {
    throw Exception(
      'eBay listing status check was unsuccessful.',
    );
  }

  final isAvailable =
      data['isAvailable'];

  if (isAvailable is! bool) {
    throw Exception(
      'eBay listing status response is missing '
      'a valid availability value.',
    );
  }

  if (!isAvailable) {
    return MonitoringCheckResult(
      currentMarketValue:
          monitor.lastMarketValue,
      checkedAt:
          DateTime.now(),
      isAvailable: false,
    );
  }

  final currentPrice =
      (data['currentPrice'] as num?)
          ?.toDouble();

  if (currentPrice == null ||
      currentPrice <= 0) {
    throw Exception(
      'eBay listing status returned '
      'an invalid price.',
    );
  }

  return MonitoringCheckResult(
    currentMarketValue:
        currentPrice,
    checkedAt:
        DateTime.now(),
    isAvailable: true,
  );
}

  Future<double> _lookupByBarcode(
    String barcode,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$backendBaseUrl/ebay-lookup/'
        '${Uri.encodeComponent(barcode)}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'eBay barcode check failed with status '
        '${response.statusCode}.',
      );
    }

    final data =
        jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        'No eBay pricing result was returned.',
      );
    }

    final productData =
        data['product'];

    if (productData
        is! Map<String, dynamic>) {
      throw Exception(
        'Invalid eBay lookup response.',
      );
    }

    final value =
        _parsePrice(
      productData['marketPrice'],
    );

    if (value <= 0) {
      throw Exception(
        'No valid market value was returned.',
      );
    }

    return value;
  }

  Future<double> _lookupByTitle(
    String title,
  ) async {
    final trimmedTitle =
        title.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception(
        'Monitor has no searchable product title.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '$backendBaseUrl/ebay-search/'
        '${Uri.encodeComponent(trimmedTitle)}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'eBay title check failed with status '
        '${response.statusCode}.',
      );
    }

    final data =
        jsonDecode(response.body);

    if (data['success'] != true) {
      throw Exception(
        'No eBay search result was returned.',
      );
    }

    final products =
        data['products'];

    if (products is! List ||
        products.isEmpty) {
      throw Exception(
        'No matching eBay products were found.',
      );
    }

    Map<String, dynamic>? selected;

    final normalizedTitle =
        trimmedTitle.toLowerCase();

    for (final item in products) {
      if (item
          is! Map<String, dynamic>) {
        continue;
      }

      final itemTitle =
          item['name']
              ?.toString()
              .trim()
              .toLowerCase();

      if (itemTitle ==
          normalizedTitle) {
        selected = item;
        break;
      }
    }

    selected ??=
        products.first
                is Map<String, dynamic>
            ? products.first
                as Map<String, dynamic>
            : null;

    if (selected == null) {
      throw Exception(
        'No usable eBay pricing result was found.',
      );
    }

    final value =
        _parsePrice(
      selected['marketPrice'],
    );

    if (value <= 0) {
      throw Exception(
        'No valid market value was returned.',
      );
    }

    return value;
  }

  double _parsePrice(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    final cleaned =
        value
            ?.toString()
            .replaceAll(
              RegExp(
                r'[^0-9.]',
              ),
              '',
            ) ??
        '';

    return double.tryParse(
          cleaned,
        ) ??
        0;
  }
}