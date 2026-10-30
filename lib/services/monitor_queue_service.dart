import 'dart:async';

class MonitorQueueService {
  bool _isProcessing = false;

  bool get isProcessing =>
      _isProcessing;

  Future<void> process<T>({
  required List<T> items,
  required Future<void> Function(T item)
      onProcess,
  Duration delayBetweenItems =
      const Duration(
    seconds: 2,
  ),
  int maxAttempts = 2,
  Duration retryDelay =
      const Duration(
    seconds: 3,
  ),
  Future<void> Function(
    T item,
    Object error,
  )? onFinalFailure,
}) async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    try {
      for (var index = 0;
          index < items.length;
          index++) {
        final item =
            items[index];

        var attempt = 1;

while (true) {
  try {
    await onProcess(
      item,
    );

    break;
  } catch (error) {
   if (attempt >=
    maxAttempts) {
  if (onFinalFailure !=
      null) {
    await onFinalFailure(
      item,
      error,
    );
  }

  break;
}

    attempt++;

    if (retryDelay >
        Duration.zero) {
      await Future<void>.delayed(
        retryDelay,
      );
    }
  }
}

        final isLastItem =
            index ==
            items.length - 1;

        if (!isLastItem &&
            delayBetweenItems >
                Duration.zero) {
          await Future<void>.delayed(
            delayBetweenItems,
          );
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
}