library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'src/data_type.dart';
import 'src/header.dart';
import 'src/message.dart';

export 'src/data_type.dart';
export 'src/message.dart';
export 'src/header.dart';

class BqspClient {
  final String host;
  final int port;

  final Map<int, Completer<Message>> _completers = {};

  Header? _header;
  Socket? _socket;
  int _queue = 1;

  BqspClient(this.host, this.port);

  Future<void> connect() async {
    _socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 10),
    );

    _socket?.listen(
      _onData,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: true,
    );
  }

  Future<Message?> send(DataType type, Object body) async {
    final message = Message(type, _queue, {
      'data': body,
    });
    _incrementQueue();

    _completers[message.header.queue] = Completer();

    _socket?.add(message.toBytes());
    await _socket?.flush();

    return _completers[message.header.queue]?.future;
  }

  Future<void> close() async {
    _completeAll('Connection closed');
    await _socket?.close();
  }

  void _onData(Uint8List data) {
    _readBytes(data);
  }

  void _readBytes(Uint8List data) {
    if (_header == null) {
      _header = Header.fromBytes(data.sublist(0, 7));
      if (data.length > 7) {
        _readBytes(data.sublist(7));
      }
      return;
    }
    final bodyLength = _header!.bodyLength;
    final body = data.sublist(0, bodyLength);
    final message = Message.fromHeader(_header!, body);

    _completers[message.header.queue]?.complete(message);
    _completers.remove(message.header.queue);

    _header = null;

    if (data.length > bodyLength) {
      _readBytes(data.sublist(bodyLength));
    }
  }

  void _completeAll(String reason) {
    _completers.forEach((_, completer) {
      completer.completeError(reason);
    });
  }

  void _onDone() {
    _completeAll('Connection closed by the server');
    _socket?.close();
  }

  void _onError(dynamic error) {
    _completeAll('Connection error: $error');
  }

  void _incrementQueue() {
    _queue = _queue + 1;
    if (_queue > 255) {
      _queue = 1;
    }
  }
}
