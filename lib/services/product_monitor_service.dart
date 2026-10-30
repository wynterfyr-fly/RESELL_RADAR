import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_monitor.dart';

// ======================================================
// PRODUCT MONITOR FIRESTORE SERVICE
// ======================================================

class ProductMonitorService {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ProductMonitorService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : firestore =
            firestore ??
            FirebaseFirestore.instance,
        firebaseAuth =
            firebaseAuth ??
            FirebaseAuth.instance;

  User? get currentUser =>
      firebaseAuth.currentUser;

  CollectionReference<
      Map<String, dynamic>>
  _monitorCollection(
    String userId,
  ) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection(
          'monitoredProducts',
        );
  }

  Future<String> saveMonitor(
    ProductMonitor monitor,
  ) async {
    final user = currentUser;

    if (user == null) {
      throw StateError(
        'A signed-in user is required to save a monitor.',
      );
    }

    final collection =
        _monitorCollection(
      user.uid,
    );

    if (monitor.id.isNotEmpty) {
      await collection
          .doc(monitor.id)
          .set(
            monitor.toMap(),
            SetOptions(
              merge: true,
            ),
          );

      return monitor.id;
    }

    final document =
        await collection.add(
      monitor.toMap(),
    );

    return document.id;
  }

  Stream<List<ProductMonitor>>
      watchMonitors() {
    final user = currentUser;

    if (user == null) {
      return Stream.value(
        const [],
      );
    }

    return _monitorCollection(
      user.uid,
    )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (document) {
            return ProductMonitor.fromMap(
              document.data(),
              id: document.id,
            );
          },
        ).toList();
      },
    );
  }

  Future<List<ProductMonitor>>
      loadMonitors() async {
    final user = currentUser;

    if (user == null) {
      return const [];
    }

    final snapshot =
        await _monitorCollection(
      user.uid,
    )
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get();

    return snapshot.docs.map(
      (document) {
        return ProductMonitor.fromMap(
          document.data(),
          id: document.id,
        );
      },
    ).toList();
  }

  Future<void> updateActiveState({
    required String monitorId,
    required bool isActive,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw StateError(
        'A signed-in user is required to update a monitor.',
      );
    }

    await _monitorCollection(
      user.uid,
    ).doc(monitorId).update({
      'isActive': isActive,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTargetPrice({
    required String monitorId,
    required double targetPrice,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw StateError(
        'A signed-in user is required to update a monitor.',
      );
    }

    await _monitorCollection(
      user.uid,
    ).doc(monitorId).update({
      'targetPrice': targetPrice,
      'alertConditionMet': false,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

Future<void> recordSuccessfulCheck({
  required String monitorId,
  required double marketValue,
  required DateTime checkedAt,
}) async {
  final user = currentUser;

  if (user == null) {
    throw StateError(
      'A signed-in user is required to update a monitor.',
    );
  }

  await _monitorCollection(
  user.uid,
).doc(monitorId).update({
  'lastMarketValue': marketValue,
  'lastCheckedAt': Timestamp.fromDate(checkedAt),
  'updatedAt': FieldValue.serverTimestamp(),
});
}

Future<void> recordListingUnavailable({
  required String monitorId,
  required DateTime checkedAt,
}) async {
  final user = currentUser;

  if (user == null) {
    throw StateError(
      'A signed-in user is required to update a monitor.',
    );
  }

  final monitorRef = _monitorCollection(
  user.uid,
).doc(monitorId);

await FirebaseFirestore.instance.runTransaction(
  (transaction) async {
    final snapshot = await transaction.get(monitorRef);

    if (!snapshot.exists) {
      throw StateError(
        'Monitor no longer exists.',
      );
    }

    final data = snapshot.data() ?? {};
    final alreadyUnavailable =
        data['listingUnavailable'] == true;

    final updates = <String, dynamic>{
      'listingUnavailable': true,
      'lastCheckedAt': Timestamp.fromDate(checkedAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!alreadyUnavailable) {
      updates['listingUnavailableAt'] =
          Timestamp.fromDate(checkedAt);
      updates['listingUnavailableAcknowledged'] = false;
    }

    transaction.update(monitorRef, updates);
  },
);
}

Future<void> recordListingAvailableAgain({
  required String monitorId,
  required DateTime checkedAt,
}) async {
  final user = currentUser;

  if (user == null) {
    throw StateError(
      'A signed-in user is required to update a monitor.',
    );
  }

  await _monitorCollection(
    user.uid,
  ).doc(monitorId).update({
    'listingUnavailable': false,
    'listingUnavailableAt': FieldValue.delete(),
    'listingUnavailableAcknowledged': false,
    'lastCheckedAt': Timestamp.fromDate(checkedAt),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> recordAlertEvaluation({
  required String monitorId,
  required bool alertConditionMet,
  required bool newlyTriggered,
}) async {
  final user = currentUser;

  if (user == null) {
    throw StateError(
      'A signed-in user is required to update a monitor.',
    );
  }

  final updates = <String, dynamic>{
    'alertConditionMet':
        alertConditionMet,
    'updatedAt':
        FieldValue.serverTimestamp(),
  };

  if (newlyTriggered) {
  updates['lastAlertedAt'] =
      FieldValue.serverTimestamp();

  updates['isAcknowledged'] =
      false;
}

  await _monitorCollection(
    user.uid,
  ).doc(monitorId).update(
        updates,
      );
}

Future<void> acknowledgeAlert(
  String monitorId,
) async {
  final user = currentUser;

  if (user == null) {
    throw StateError(
      'A signed-in user is required to acknowledge an alert.',
    );
  }

  await _monitorCollection(
    user.uid,
  ).doc(monitorId).update({
    'isAcknowledged': true,
    'updatedAt':
        FieldValue.serverTimestamp(),
  });
}

Future<void> acknowledgeListingUnavailable(
  String monitorId,
) async {
  final user = currentUser;

  if (user == null) {
    throw StateError(
      'A signed-in user is required to acknowledge an alert.',
    );
  }

  await _monitorCollection(
    user.uid,
  ).doc(monitorId).update({
    'listingUnavailableAcknowledged': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<void> acknowledgeAllTriggeredAlerts() async {
  final user = currentUser;

  if (user == null) {
    throw StateError(
      'A signed-in user is required to acknowledge alerts.',
    );
  }

  final snapshot =
      await _monitorCollection(
    user.uid,
  )
          .where(
            'alertConditionMet',
            isEqualTo: true,
          )
          .get();

  final unacknowledgedDocs =
      snapshot.docs.where(
    (document) {
      final data =
          document.data();

      return data['isAcknowledged'] !=
          true;
    },
  ).toList();

  if (unacknowledgedDocs.isEmpty) {
    return;
  }

  final batch =
      firestore.batch();

  for (final document
      in unacknowledgedDocs) {
    batch.update(
      document.reference,
      {
        'isAcknowledged': true,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );
  }

  await batch.commit();
}

  Future<void> deleteMonitor(
    String monitorId,
  ) async {
    final user = currentUser;

    if (user == null) {
      throw StateError(
        'A signed-in user is required to delete a monitor.',
      );
    }

    await _monitorCollection(
      user.uid,
    ).doc(monitorId).delete();
  }
}