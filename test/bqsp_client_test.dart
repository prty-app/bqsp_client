import 'package:flutter_test/flutter_test.dart';
import 'package:bqsp_client/bqsp_client.dart';

void main() {
  test('Ping', () async {
    final client = BqspClient();
    await client.connect('localhost', 7589);
    final result = await client.query(const Ping());
    expect(result, const Ok());
    client.close();
  });
}
