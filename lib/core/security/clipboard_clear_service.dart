import 'dart:async';

import 'package:flutter/services.dart';

abstract interface class ClipboardGateway {
  Future<void> writeText(String value);

  Future<String?> readText();
}

abstract interface class ClipboardClearTimer {
  void cancel();
}

typedef ClipboardClearTimerFactory =
    ClipboardClearTimer Function(
      Duration delay,
      Future<void> Function() callback,
    );

/// Copies values and clears them later only if the clipboard is unchanged.
class ClipboardClearService {
  ClipboardClearService({
    ClipboardGateway? clipboard,
    ClipboardClearTimerFactory? timerFactory,
    DateTime Function()? clock,
  }) : _clipboard = clipboard ?? const FlutterClipboardGateway(),
       _timerFactory = timerFactory ?? _createTimer,
       _clock = clock ?? DateTime.now;

  final ClipboardGateway _clipboard;
  final ClipboardClearTimerFactory _timerFactory;
  final DateTime Function() _clock;
  ClipboardClearTimer? _timer;
  String? _expectedClipboardText;
  DateTime? _expiresAt;
  int _copyGeneration = 0;
  bool _disposed = false;

  Future<void> copyAndSchedule(String value, Duration delay) async {
    if (_disposed) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    final generation = ++_copyGeneration;
    _expectedClipboardText = value;
    _expiresAt = _clock().add(delay);
    await _clipboard.writeText(value);
    if (_disposed ||
        _expectedClipboardText != value ||
        _copyGeneration != generation) {
      return;
    }
    if (delay <= Duration.zero) {
      await _clearIfUnchanged(value, generation);
      return;
    }
    _timer = _timerFactory(delay, () => _clearIfUnchanged(value, generation));
  }

  Future<void> clearIfExpired() async {
    final expectedText = _expectedClipboardText;
    final expiresAt = _expiresAt;
    if (_disposed ||
        expectedText == null ||
        expiresAt == null ||
        _clock().isBefore(expiresAt)) {
      return;
    }
    await _clearIfUnchanged(expectedText, _copyGeneration);
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _expectedClipboardText = null;
    _expiresAt = null;
  }

  Future<void> _clearIfUnchanged(String expectedText, int generation) async {
    _timer = null;
    if (_disposed ||
        _expectedClipboardText != expectedText ||
        _copyGeneration != generation) {
      return;
    }
    if (await _clipboard.readText() == expectedText &&
        _expectedClipboardText == expectedText &&
        _copyGeneration == generation) {
      await _clipboard.writeText('');
    }
    if (_copyGeneration == generation) {
      _expectedClipboardText = null;
      _expiresAt = null;
    }
  }

  static ClipboardClearTimer _createTimer(
    Duration delay,
    Future<void> Function() callback,
  ) {
    return _DartClipboardClearTimer(Timer(delay, () => unawaited(callback())));
  }
}

class FlutterClipboardGateway implements ClipboardGateway {
  const FlutterClipboardGateway();

  @override
  Future<String?> readText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  @override
  Future<void> writeText(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }
}

class _DartClipboardClearTimer implements ClipboardClearTimer {
  const _DartClipboardClearTimer(this._timer);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
