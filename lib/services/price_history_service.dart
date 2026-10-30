import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_snapshot.dart';

class PriceHistoryService {
  String createProductKey(String title) {
  var normalized = title
      .trim()
      .toLowerCase()
      .replaceAll(
        RegExp(r'[^a-z0-9]+'),
        '_',
      );

  while (normalized.startsWith('_')) {
    normalized =
        normalized.substring(1);
  }

  while (normalized.endsWith('_')) {
    normalized =
        normalized.substring(
      0,
      normalized.length - 1,
    );
  }

  if (normalized.isEmpty) {
    return 'unknown_product';
  }

  return normalized;
}
  PriceSnapshot createSnapshot({
    required double marketValue,
    required double lowestPrice,
    required double averagePrice,
    required double medianPrice,
    required double highestPrice,
    required int listingsChecked,
    required String confidence,
  }) {
    return PriceSnapshot(
      marketValue: marketValue,
      lowestPrice: lowestPrice,
      averagePrice: averagePrice,
      medianPrice: medianPrice,
      highestPrice: highestPrice,
      listingsChecked: listingsChecked,
      confidence: confidence,
      recordedAt: DateTime.now(),
    );
  }
  Future<void> saveSnapshot({
  required String userId,
  required String productKey,
  required PriceSnapshot snapshot,
}) async {
  try {
    final docRef =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('priceHistory')
        .doc(productKey)
        .collection('snapshots')
        .add(
          snapshot.toMap(),
        );

print(
  'PRICE HISTORY SAVE SUCCESS | '
  'userId=$userId | '
  'productKey=$productKey | '
  'snapshotId=${docRef.id} | '
  'path=users/$userId/priceHistory/$productKey/snapshots/${docRef.id} | '
  'marketValue=${snapshot.marketValue}',
);
  } catch (e) {
    print(
      'PRICE HISTORY SAVE FAILED | '
      'productKey=$productKey | '
      'error=$e',
    );

    rethrow;
  }
}

Future<List<PriceSnapshot>> loadSnapshots({
  required String userId,
  required String productKey,
  int limit = 50,
}) async {
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('priceHistory')
          .doc(productKey)
          .collection('snapshots')
          .orderBy(
            'recordedAt',
            descending: true,
          )
          .limit(limit)
          .get();

  return querySnapshot.docs
      .map(
        (doc) => PriceSnapshot.fromMap(
          doc.data(),
        ),
      )
      .toList();
}

String calculateMarketTrend(
  List<PriceSnapshot> snapshots,
) {
  if (snapshots.length < 2) {
    return 'Not Enough Data';
  }

  final latest =
      snapshots[0].marketValue;

  final previous =
      snapshots[1].marketValue;

  if (previous <= 0) {
    return 'Not Enough Data';
  }

  final changePercent =
      ((latest - previous) /
              previous) *
          100;

  if (changePercent >= 2) {
    return 'Rising';
  }

  if (changePercent <= -2) {
    return 'Falling';
  }

  return 'Stable';
}

double calculateMarketChangePercent(
  List<PriceSnapshot> snapshots,
) {
  if (snapshots.length < 2) {
    return 0;
  }

  final latest =
      snapshots[0].marketValue;

  final previous =
      snapshots[1].marketValue;

  if (previous <= 0) {
    return 0;
  }

  return ((latest - previous) /
          previous) *
      100;
}

}