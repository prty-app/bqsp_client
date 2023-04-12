import 'dart:typed_data';

import 'message.dart';

class AddFriend extends Message {
  AddFriend(this.id);

  final String id;

  factory AddFriend.fromMessage(Uint8List body) {
    final id = String.fromCharCodes(body);
    return AddFriend(id);
  }

  @override
  String toString() {
    return 'AddFriend { id: "$id" }';
  }
}
