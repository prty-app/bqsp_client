import 'dart:async';
import 'dart:io';

class BqspClient {
  late final Socket _socket;
  late final _buffer = StringBuffer();
  var _completer = Completer<void>();

  Future connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
    _socket.listen((data) {
      _buffer.write(String.fromCharCodes(data));
      if (_buffer.toString().endsWith('\x00')) {
        _completer.complete();
      }
    });
  }

  Future<StringBuffer> sendAndWait(String message) async {
    _socket.write(message);
    await _completer.future;
    _completer = Completer<void>();
    return _buffer;
  }

  void send(String message) {
    _socket.write(message);
  }

  Future<StringBuffer> receive() async {
    await _completer.future;
    _completer = Completer<void>();
    return _buffer;
  }

  Future close() async {
    _socket.destroy();
  }
}
