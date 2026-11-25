import 'package:flutter_test/flutter_test.dart';
import 'package:llavero/core/security/clipboard_clear_service.dart';

void main() {
  group('ClipboardClearService', () {
    test('clears copied text after the configured delay', () async {
      final clipboard = _MemoryClipboard();
      final timer = _FakeClipboardTimerFactory();
      final service = ClipboardClearService(
        clipboard: clipboard,
        timerFactory: timer.create,
      );
      addTearDown(service.dispose);

      await service.copyAndSchedule(
        'private value',
        const Duration(seconds: 30),
      );
      expect(clipboard.text, 'private value');
      expect(timer.delay, const Duration(seconds: 30));

      await timer.fire();

      expect(clipboard.text, isEmpty);
    });

    test(
      'does not erase content copied to the clipboard later by another app',
      () async {
        final clipboard = _MemoryClipboard();
        final timer = _FakeClipboardTimerFactory();
        final service = ClipboardClearService(
          clipboard: clipboard,
          timerFactory: timer.create,
        );
        addTearDown(service.dispose);

        await service.copyAndSchedule(
          'private value',
          const Duration(seconds: 30),
        );
        clipboard.text = 'new clipboard value';
        await timer.fire();

        expect(clipboard.text, 'new clipboard value');
      },
    );

    test(
      'clears expired copied text when the app returns after suspension',
      () async {
        final clipboard = _MemoryClipboard();
        final timer = _FakeClipboardTimerFactory();
        var now = DateTime.utc(2026, 11, 25);
        final service = ClipboardClearService(
          clipboard: clipboard,
          timerFactory: timer.create,
          clock: () => now,
        );
        addTearDown(service.dispose);

        await service.copyAndSchedule(
          'private value',
          const Duration(seconds: 30),
        );
        now = now.add(const Duration(seconds: 31));
        await service.clearIfExpired();

        expect(clipboard.text, isEmpty);
      },
    );
  });
}

class _MemoryClipboard implements ClipboardGateway {
  String text = '';

  @override
  Future<String?> readText() async => text;

  @override
  Future<void> writeText(String value) async => text = value;
}

class _FakeClipboardTimerFactory {
  Duration? delay;
  Future<void> Function()? _callback;
  bool _cancelled = false;

  ClipboardClearTimer create(Duration delay, Future<void> Function() callback) {
    this.delay = delay;
    _callback = callback;
    return _FakeClipboardTimer(() => _cancelled = true);
  }

  Future<void> fire() async {
    if (!_cancelled) {
      await _callback?.call();
    }
  }
}

class _FakeClipboardTimer implements ClipboardClearTimer {
  _FakeClipboardTimer(this._onCancel);

  final void Function() _onCancel;

  @override
  void cancel() => _onCancel();
}
