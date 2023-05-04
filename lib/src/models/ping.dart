import 'dart:typed_data';

import 'package:bqsp_client/bqsp_client.dart';

class Ping extends Message {
  const Ping();

  static const int type = 0x04;

  @override
  Ping fromMessage(Uint8List body) => const Ping();

  @override
  int getSize() => 6;

  @override
  int getType() => type;

  @override
  Uint8List toBytes() {
    final message = Uint8List.fromList([34, 80, 105, 110, 103, 34]);
    return message;
  }

  @override
  String toString() => 'Ping {}';
}
