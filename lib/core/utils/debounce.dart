import 'dart:async';
import '../../core/constants/constants.dart';

/// Debounce utility for delaying function execution
class Debounce {
  Timer? _timer;
  final Duration _delay;

  Debounce([Duration? delay]) : _delay = delay ?? AppConstants.debounceNormal;

  /// Execute function after delay, cancelling previous execution
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(_delay, action);
  }

  /// Cancel pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if there's a pending execution
  bool get isPending => _timer?.isActive ?? false;

  /// Dispose of the debouncer
  void dispose() {
    cancel();
  }
}

/// Throttled function execution - ensures function runs at most once per interval
class Throttle {
  Timer? _timer;
  final Duration _interval;
  bool _isReady = true;

  Throttle([Duration? interval]) : _interval = interval ?? AppConstants.debounceNormal;

  /// Execute function immediately if ready, otherwise queue for next interval
  void call(void Function() action) {
    if (_isReady) {
      action();
      _isReady = false;
      _timer = Timer(_interval, () => _isReady = true);
    }
  }

  /// Cancel pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _isReady = true;
  }

  /// Check if ready for immediate execution
  bool get isReady => _isReady;

  /// Dispose of the throttler
  void dispose() {
    cancel();
  }
}

/// Extension on functions to add debouncing
extension DebounceExtensions on void Function() {
  /// Create a debounced version of this function
  DebouncedFunction debounced([Duration? delay]) {
    return DebouncedFunction(this, delay);
  }

  /// Create a throttled version of this function
  ThrottledFunction throttled([Duration? interval]) {
    return ThrottledFunction(this, interval);
  }
}

/// Debounced function wrapper
class DebouncedFunction {
  final void Function() _action;
  final Debounce _debounce;

  DebouncedFunction(this._action, [Duration? delay]) : _debounce = Debounce(delay);

  /// Call the debounced function
  void call() => _debounce.call(_action);

  /// Cancel pending execution
  void cancel() => _debounce.cancel();

  /// Check if there's a pending execution
  bool get isPending => _debounce.isPending;

  /// Dispose of the debounced function
  void dispose() => _debounce.dispose();
}

/// Throttled function wrapper
class ThrottledFunction {
  final void Function() _action;
  final Throttle _throttle;

  ThrottledFunction(this._action, [Duration? interval]) : _throttle = Throttle(interval);

  /// Call the throttled function
  void call() => _throttle.call(_action);

  /// Cancel pending execution
  void cancel() => _throttle.cancel();

  /// Check if ready for immediate execution
  bool get isReady => _throttle.isReady;

  /// Dispose of the throttled function
  void dispose() => _throttle.dispose();
}
