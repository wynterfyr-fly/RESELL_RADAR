import 'dart:async';

class MonitorSchedulerService {
 Timer? _timer;
 bool _isChecking = false;

 DateTime? _lastRun;
 Duration? _interval;

 DateTime? get lastRun => _lastRun;
 Duration? get interval => _interval;

DateTime? get nextRun {
  if (_lastRun == null ||
      _interval == null) {
    return null;
  }

  return _lastRun!.add(
    _interval!,
  );
}

  bool get isRunning =>
      _timer?.isActive ?? false;

  void start({
  required Duration interval,
  required Future<void> Function()
      onCheck,
}) {
 stop();

_interval = interval;

_timer =
    Timer.periodic(
  interval,
  (_) {
    if (_isChecking) {
      return;
    }

    _isChecking = true;
    _lastRun = DateTime.now();
    unawaited(
      onCheck().whenComplete(
        () {
          _isChecking = false;
        },
      ),
    );
  },
);
}

  void stop() {
  _timer?.cancel();
  _timer = null;
  _isChecking = false;
  _interval = null;
}

  void dispose() {
    stop();
  }
}