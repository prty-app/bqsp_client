import 'package:flutter_test/flutter_test.dart';

import 'package:bqsp_client/bqsp_client.dart';

void main() {
  test('create client, send and receive a message', () async {
    final client = BqspClient();
    await client.connect('localhost', 8080);
    final response = await client.sendAndWait('Hello, world!\x00');
    expect(response.toString(), 'Hello, world!\x00');
    await client.close();
  });

  test('create client, send a message, receive a message', () async {
    final client = BqspClient();
    await client.connect('localhost', 8080);
    client.send('Hello, world!\x00');
    final response = await client.receive();
    expect(response.toString(), 'Hello, world!\x00');
    await client.close();
  });
}
