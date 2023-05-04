import 'dart:typed_data';

abstract class Message<T> {
  const Message();

  Uint8List toBytes();

  int getSize();

  int getType();

  T fromMessage(Uint8List body);
}
