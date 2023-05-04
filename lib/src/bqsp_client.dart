import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'models/models.dart';

class BqspClient {
  late final Socket _socket;
  final _messages = <int, Completer<Message>>{};
  var _queuePointer = 1;

  Future connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
    _socket.listen((data) {
      final msg = _parseMessage(data);
      final queue = _getQueue(data);
      _messages[queue]!.complete(msg);
    });
  }

  Future<T> query<T extends Message>(Message message) async {
    final queuePointer = _queuePointer;
    _queuePointer = _queuePointer % 3 + 1;
    _messages[queuePointer] = Completer<Message>();

    final messageBytes = _buildMessage(
      message.getSize(),
      message.getType(),
      queuePointer,
      message.toBytes(),
    );
    send(messageBytes);

    final res = await _messages[queuePointer]!.future;
    _messages.remove(queuePointer);

    return res as T;
  }

  void send(Uint8List message) => _socket.add(message);

  void close() => _socket.destroy();

  Uint8List _buildMessage(int size, int type, int queue, Uint8List message) {
    final header = Uint8List.fromList([
      size & 0xFF,
      (size >> 8) & 0xFF,
      (size >> 16) & 0xFF,
      (size >> 24) & 0xFF,
      type & 0xFF,
      (type >> 8) & 0xFF,
      queue & 0xFF,
    ]);
    return Uint8List.fromList([...header, ...message]);
  }

  Message _parseMessage(Uint8List message) {
    final type = _getType(message);
    final body = message.sublist(7);
    switch (type) {
      case Ok.type:
        return const Ok();
      default:
        throw Exception('Unknown message type: $type');
    }
  }

  int _getSize(Uint8List message) {
    return message[0] +
        (message[1] << 8) +
        (message[2] << 16) +
        (message[3] << 24);
  }

  int _getType(Uint8List message) {
    return message[4] + (message[5] << 8);
  }

  int _getQueue(Uint8List message) {
    return message[6];
  }
}
