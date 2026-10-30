import 'package:cloud_firestore/cloud_firestore.dart';

// ======================================================
// PRODUCT MONITOR MODEL
// ======================================================

class ProductMonitor {
  final String id;
  final String productTitle;
  final String barcode;
  final String imagePath;
  final String marketplace;
  final String marketplaceItemId;

  final double targetPrice;
  final String comparisonType;

  final bool isActive;
  final bool alertConditionMet;
  final bool isAcknowledged;
  final bool listingUnavailable;
  final bool listingUnavailableAcknowledged;
  final DateTime? listingUnavailableAt;

  final double lastMarketValue;

  final DateTime? lastCheckedAt;
  final DateTime? lastAlertedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductMonitor({
    this.id = '',
    required this.productTitle,
    this.barcode = '',
    this.imagePath = '',
    this.marketplace = 'eBay',
    this.marketplaceItemId = '',
    required this.targetPrice,
    this.comparisonType = 'atOrBelow',
    this.isActive = true,
    this.alertConditionMet = false,
    this.isAcknowledged = false,
    this.listingUnavailable = false,
    this.listingUnavailableAcknowledged = false,
    this.listingUnavailableAt,
    this.lastMarketValue = 0,
    this.lastCheckedAt,
    this.lastAlertedAt,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productTitle': productTitle,
      'barcode': barcode,
      'imagePath': imagePath,
      'marketplace': marketplace,
      'marketplaceItemId': marketplaceItemId,
      'targetPrice': targetPrice,
      'comparisonType': comparisonType,
      'isActive': isActive,
      'alertConditionMet': alertConditionMet,
      'isAcknowledged': isAcknowledged,
      'listingUnavailable': listingUnavailable,
      'listingUnavailableAcknowledged': 
       listingUnavailableAcknowledged,
    'listingUnavailableAt': listingUnavailableAt == null
    ? null
    : Timestamp.fromDate(listingUnavailableAt!),
      'lastMarketValue': lastMarketValue,
      'lastCheckedAt': lastCheckedAt == null
          ? null
          : Timestamp.fromDate(
              lastCheckedAt!,
            ),
      'lastAlertedAt': lastAlertedAt == null
          ? null
          : Timestamp.fromDate(
              lastAlertedAt!,
            ),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(
              createdAt!,
            ),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ProductMonitor.fromMap(
    Map<String, dynamic> map, {
    String id = '',
  }) {
    return ProductMonitor(
      id: id,
      productTitle:
          map['productTitle']
              ?.toString() ??
          '',
      barcode:
          map['barcode']
              ?.toString() ??
          '',
      imagePath:
          map['imagePath']
              ?.toString() ??
          '',
      marketplace:
          map['marketplace']
              ?.toString() ??
          'eBay',
      marketplaceItemId:
    map['marketplaceItemId']
        ?.toString() ??
    '',
      targetPrice:
          (map['targetPrice']
                      as num?)
                  ?.toDouble() ??
              0,
      comparisonType:
          map['comparisonType']
              ?.toString() ??
          'atOrBelow',
      isActive:
          map['isActive']
                  as bool? ??
              true,
      alertConditionMet:
    map['alertConditionMet']
            as bool? ??
        false,
      isAcknowledged:
    map['isAcknowledged'] as bool? ?? false,
    listingUnavailable:
    map['listingUnavailable'] as bool? ?? false,
    listingUnavailableAcknowledged:
    map['listingUnavailableAcknowledged'] as bool? ?? false,
    listingUnavailableAt:
    _dateFromValue(map['listingUnavailableAt']),
    lastMarketValue:
    (map['lastMarketValue'] as num?)?.toDouble() ?? 0,
      lastCheckedAt:
          _dateFromValue(
        map['lastCheckedAt'],
      ),
      lastAlertedAt:
          _dateFromValue(
        map['lastAlertedAt'],
      ),
      createdAt:
          _dateFromValue(
        map['createdAt'],
      ),
      updatedAt:
          _dateFromValue(
        map['updatedAt'],
      ),
    );
  }

  ProductMonitor copyWith({
    String? id,
    String? productTitle,
    String? barcode,
    String? imagePath,
    String? marketplace,
    String? marketplaceItemId,
    double? targetPrice,
    String? comparisonType,
    bool? isActive,
    bool? alertConditionMet,
    bool? isAcknowledged,
    bool? listingUnavailable,
    bool? listingUnavailableAcknowledged,
    DateTime? listingUnavailableAt,
    double? lastMarketValue,
    DateTime? lastCheckedAt,
    DateTime? lastAlertedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductMonitor(
      id: id ?? this.id,
      productTitle:
          productTitle ??
          this.productTitle,
      barcode:
          barcode ??
          this.barcode,
      imagePath:
          imagePath ??
          this.imagePath,
     marketplace:
    marketplace ??
    this.marketplace,
marketplaceItemId:
    marketplaceItemId ??
    this.marketplaceItemId,
targetPrice:
          targetPrice ??
          this.targetPrice,
      comparisonType:
          comparisonType ??
          this.comparisonType,
      isActive:
          isActive ??
          this.isActive,
      alertConditionMet:
    alertConditionMet ??
    this.alertConditionMet,
isAcknowledged:
    isAcknowledged ??
    this.isAcknowledged,
    listingUnavailable:
    listingUnavailable ?? this.listingUnavailable,
listingUnavailableAcknowledged:
    listingUnavailableAcknowledged ??
    this.listingUnavailableAcknowledged,
listingUnavailableAt:
    listingUnavailableAt ?? this.listingUnavailableAt,
lastMarketValue:
          lastMarketValue ??
          this.lastMarketValue,
      lastCheckedAt:
          lastCheckedAt ??
          this.lastCheckedAt,
      lastAlertedAt:
          lastAlertedAt ??
          this.lastAlertedAt,
      createdAt:
          createdAt ??
          this.createdAt,
      updatedAt:
          updatedAt ??
          this.updatedAt,
    );
  }

  bool shouldTriggerAlert(
    double currentMarketValue,
  ) {
    if (!isActive ||
        currentMarketValue <= 0) {
      return false;
    }

    switch (comparisonType) {
      case 'atOrBelow':
        return currentMarketValue <=
            targetPrice;

      case 'atOrAbove':
        return currentMarketValue >=
            targetPrice;

      default:
        return false;
    }
  }

  static DateTime? _dateFromValue(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(
        value,
      );
    }

    return null;
  }
}