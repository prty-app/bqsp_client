/// A Dart client for the BQSP protocol.
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'src/header.dart';
import 'src/message.dart';

export 'src/message.dart';
export 'src/header.dart';

/// A Dart client for the BQSP protocol.
class BqspClient {
  final String host;
  final int port;

  final Map<int, Completer<Message>> _completers = {};

  Header? _header;
  Socket? _socket;
  int _queue = 1;

  /// Creates a new instance of the BqspClient.
  ///
  /// This constructor initializes a new BqspClient with the provided host and port.
  /// The host and port are used to establish a connection to the server
  /// when the `connect` method is called.
  BqspClient(this.host, this.port);

  /// Establishes a connection to a server.
  ///
  /// This method creates a socket connection to the specified host and port.
  /// The connection attempt will timeout after 10 seconds.
  ///
  /// This is an asynchronous method, and it returns a `Future<void>`.
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

  /// Sends a message to the server.
  ///
  /// This method creates a new message with the given type and body,
  /// and sends it to the server. The message is added to the socket's write buffer,
  /// and the buffer is then flushed to ensure that the message is sent immediately.
  ///
  /// This is an asynchronous method, and it returns a `Future<Message?>`.
  /// The future completes when a response to the sent message is received.
  Future<Message?> send(int type, Object body) async {
    final message = Message(type, _queue, body);
    _incrementQueue();

    _completers[message.header.queue] = Completer();

    _socket?.add(message.toBytes());
    await _socket?.flush();

    return _completers[message.header.queue]?.future;
  }

  /// Closes the connection to the server.
  ///
  /// This method completes all pending requests with the message 'Connection closed'
  /// and then closes the socket connection to the server.
  ///
  /// This is an asynchronous method, and it returns a `Future<void>`.
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
