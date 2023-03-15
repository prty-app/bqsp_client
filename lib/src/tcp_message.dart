import 'dart:convert';
import 'dart:typed_data';

class TcpMessage {
  const TcpMessage(this.bytes);

  final Uint8List bytes;

  String get body => utf8.decode(bytes, allowMalformed: true);
}
