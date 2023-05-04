import 'dart:convert';
import 'dart:typed_data';

import 'message.dart';

class RateUser implements Message {
  RateUser(
    this.value,
    this.desc,
    this.user,
  );

  final int value;
  final String desc;
  final String user;

  factory RateUser.fromMessage(Uint8List body) {
    final json = jsonDecode(utf8.decode(body));
    return RateUser(
      json['value'] as int,
      json['desc'] as String,
      json['user'] as String,
    );
  }

  @override
  String toString() {
    return 'RateUser {\n\tvalue: $value,\n\tdesc: "$desc",\n\tuser: "$user"\n}';
  }
}
