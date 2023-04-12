import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'models/models.dart';

class BqspClient {
  late final Socket _socket;
  final _messages = <int, Completer<Message>>{};
  var _queuePointer = 0;

  Future connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
    _socket.listen((data) {
      final msg = _parseMessage(data);
      final queue = _getQueue(data);
      _messages[queue]!.complete(msg);
    });
  }

  Future<T> query<T extends Message>(Uint8List message) async {
    _socket.add(message);
    _messages[_queuePointer] = Completer<Message>();
    final res = await _messages[_queuePointer]!.future;
    _messages.remove(_queuePointer);
    _queuePointer = _queuePointer % 3 + 1;
    return res as T;
  }

  void send(Uint8List message) {
    _socket.add(message);
  }

  void close() {
    _socket.destroy();
  }

  Message _parseMessage(Uint8List message) {
    final type = _getType(message);
    final body = message.sublist(11);
    switch (type) {
      case 0x01:
        return AddFriend.fromMessage(body);
      default:
        throw Exception('Unknown message type: $type');
    }
  }

  int _getSize(Uint8List message) {
    return message[0] +
        (message[1] << 8) +
        (message[2] << 16) +
        (message[3] << 24) +
        (message[4] << 32) +
        (message[5] << 40) +
        (message[6] << 48) +
        (message[7] << 56);
  }

  int _getType(Uint8List message) {
    return message[8] + (message[9] << 8);
  }

  int _getQueue(Uint8List message) {
    return message[10];
  }
}
