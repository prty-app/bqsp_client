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

  final List<Completer<Message>> _completers = [];
  final int _queue = 1;

  bool _connected = false;
  Header? _header;
  Socket? _socket;

  /// Returns whether the client is connected to a server.
  bool get connected => _connected;

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
    _connected = true;
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

    final completer = Completer<Message>();
    _completers.add(completer);

    _socket?.add(message.toBytes());
    await _socket?.flush();

    return completer.future;
  }

  /// Closes the connection to the server.
  ///
  /// This method completes all pending requests with the message 'Connection closed'
  /// and then closes the socket connection to the server.
  ///
  /// This is an asynchronous method, and it returns a `Future<void>`.
  Future<void> close() async {
    _completeAll('Connection closed');
    _connected = false;
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

    final completer = _completers.removeAt(0);
    completer.complete(message);

    _header = null;

    if (data.length > bodyLength) {
      _readBytes(data.sublist(bodyLength));
    }
  }

  void _completeAll(String reason) {
    for (final completer in _completers) {
      completer.completeError(reason);
    }
  }

  void _onDone() {
    _completeAll('Connection closed by the server');
    _connected = false;
    _socket?.close();
  }

  void _onError(dynamic error) {
    _completeAll('Connection error: $error');
    _connected = false;
  }
}
