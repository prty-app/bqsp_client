import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bqsp_client/bqsp_client.dart';

void main() {
  test('test', () async {
    final client = BqspClient();
    await client.connect('localhost', 8080);
    {
      final msg =
          Uint8List.fromList([4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 66, 81, 83, 80]);
      final AddFriend res = await client.query(msg);
      print(msg);
      print(res);
    }
    {
      final msg =
          Uint8List.fromList([4, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 66, 81, 83, 80]);
      final AddFriend res = await client.query(msg);
      print(msg);
      print(res);
    }
    client.close();
  });
}
