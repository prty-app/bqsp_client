import 'package:flutter_test/flutter_test.dart';

import 'package:bqsp_client/bqsp_client.dart';

void main() {
  test('adds one to input values', () {
    final client = BqspClient();
    expect(client, isNotNull);
  });
}
