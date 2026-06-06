import 'dart:async';

class SessionExpiredEvent {
  SessionExpiredEvent._();

  static final _controller = StreamController<void>.broadcast();

  static Stream<void> get stream => _controller.stream;

  static void trigger() {
    _controller.add(null);
  }
}
