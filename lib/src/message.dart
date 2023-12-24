import 'dart:convert';
import 'dart:typed_data';

import 'header.dart';

class Message {
  late final Header header;
  late final Object body;
  late final Uint8List rawBody;

  Message(int dataType, int queue, this.body) {
    assert(queue > 0 && queue <= 255);
    rawBody = Uint8List.fromList(utf8.encode(jsonEncode(body)));
    header = Header(rawBody.length, dataType, queue);
  }

  Message.fromBytes(Uint8List bytes) {
    header = Header.fromBytes(bytes.sublist(0, 7));
    rawBody = bytes.sublist(7);
    body = jsonDecode(utf8.decode(bytes.sublist(7)));
  }

  Message.fromHeader(this.header, this.rawBody) {
    body = jsonDecode(utf8.decode(rawBody));
  }

  Uint8List toBytes() {
    return Uint8List.fromList([...header.toBytes(), ...rawBody]);
  }

  @override
  String toString() {
    return 'Message{header: $header, body: $body}';
  }
}
