import 'dart:typed_data';

import 'data_type.dart';

class Header {
  late final int bodyLength;
  late final DataType dataType;
  late final int queue;

  Header(this.bodyLength, this.dataType, this.queue)
      : assert(queue > 0 && queue <= 255);

  Header.fromBytes(Uint8List bytes) {
    bodyLength =
        bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | (bytes[3] << 24);
    dataType = DataType.fromId(bytes[4] | (bytes[5] << 8));
    queue = bytes[6];
  }

  Uint8List toBytes() {
    return Uint8List.fromList([
      bodyLength & 0xFF,
      (bodyLength >> 8) & 0xFF,
      (bodyLength >> 16) & 0xFF,
      (bodyLength >> 24) & 0xFF,
      dataType.id & 0xFF,
      (dataType.id >> 8) & 0xFF,
      queue & 0xFF,
    ]);
  }

  @override
  String toString() {
    return 'Header{bodyLength: $bodyLength, dataType: $dataType, queue: $queue}';
  }
}
