import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class NotificationService {
  Future<bool> requestPermission() async {
    if (!kIsWeb) {
      return false;
    }

    final permission =
    (await web.Notification
        .requestPermission()
        .toDart)
        .toDart;

return permission ==
    'granted';
  }

  Future<void> notifyTargetReached({
    required String productTitle,
    required String marketplace,
    required double targetPrice,
    required double currentMarketValue,
  }) async {
    debugPrint(
      'RESELL RADAR NOTIFICATION | '
      'TARGET REACHED | '
      'product=$productTitle | '
      'marketplace=$marketplace | '
      'target=${targetPrice.toStringAsFixed(2)} | '
      'current=${currentMarketValue.toStringAsFixed(2)}',
    );

    if (!kIsWeb) {
      return;
    }

    final permission =
        web.Notification.permission;

    if (permission !=
        'granted') {
      return;
    }

    web.Notification(
      'Resell Radar — Target Reached!',
      web.NotificationOptions(
        body:
            '$productTitle\n'
            '$marketplace market value: '
            '\$${currentMarketValue.toStringAsFixed(2)}\n'
            'Target: '
            '\$${targetPrice.toStringAsFixed(2)} or below',
      ),
    );
  }
}