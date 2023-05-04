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

  Future<T> query<T extends Message>(Uint8List message) async {
    final queuePointer = _queuePointer;
    _queuePointer = _queuePointer % 3 + 1;
    _messages[queuePointer] = Completer<Message>();

    send(message);

    final res = await _messages[queuePointer]!.future;
    _messages.remove(queuePointer);

    return res as T;
  }

  void send(Uint8List message) => _socket.add(message);

  void close() => _socket.destroy();

  Message _parseMessage(Uint8List message) {
    final type = _getType(message);
    final body = message.sublist(7);
    switch (type) {
      case 0x1:
        return AddFriend.fromMessage(body);
      case 0xE:
        return RateUser.fromMessage(body);
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
