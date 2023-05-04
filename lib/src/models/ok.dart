import 'dart:typed_data';

import '../../bqsp_client.dart';

class Ok extends Message {
  const Ok();

  static const int type = 0x1D;

  @override
  Ok fromMessage(Uint8List body) => const Ok();

  @override
  int getSize() => 2;

  @override
  int getType() => type;

  @override
  Uint8List toBytes() {
    return Uint8List.fromList([34, 79, 107, 34]);
  }

  @override
  String toString() => 'Ok {}';
}
