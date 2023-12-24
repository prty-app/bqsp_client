import 'dart:convert';
import 'dart:typed_data';

import 'package:bqsp_client/bqsp_client.dart';
import 'package:test/test.dart';

void main() {
  group('Header Tests', () {
    test('Header initialization', () {
      final int bodyLength = 100;
      final int dataType = 1;
      final int queue = 42;

      final Header header = Header(bodyLength, dataType, queue);

      expect(header.bodyLength, equals(bodyLength));
      expect(header.dataType, equals(dataType));
      expect(header.queue, equals(queue));
    });

    test('Header fromBytes', () {
      final Uint8List bytes = Uint8List.fromList(
        [100, 0, 0, 0, 1, 0, 42],
      );

      final Header header = Header.fromBytes(bytes);

      expect(header.bodyLength, equals(100));
      expect(header.dataType, equals(1));
      expect(header.queue, equals(42));
    });

    test('Header toBytes', () {
      final int bodyLength = 100;
      final int dataType = 1;
      final int queue = 42;

      final Header header = Header(bodyLength, dataType, queue);
      final Uint8List expectedBytes = Uint8List.fromList(
        [100, 0, 0, 0, 1, 0, 42],
      );

      final Uint8List resultBytes = header.toBytes();

      expect(resultBytes, equals(expectedBytes));
    });

    test('Header queue validation', () {
      expect(
        () => Header(100, 1, 256),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Header(100, 1, 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Message Tests', () {
    test('Message initialization', () {
      final int dataType = 1;
      final int queue = 42;
      final Map<String, dynamic> body = {'key': 'value'};

      final Message message = Message(dataType, queue, body);

      expect(message.header.bodyLength, equals(jsonEncode(body).length));
      expect(message.header.dataType, equals(dataType));
      expect(message.header.queue, equals(queue));
      expect(message.body, equals(body));
    });

    test('Message fromBytes', () {
      final int dataType = 1;
      final int queue = 42;
      final Map<String, dynamic> body = {'key': 'value'};
      final Message originalMessage = Message(dataType, queue, body);

      final Uint8List bytes = originalMessage.toBytes();

      final Message parsedMessage = Message.fromBytes(bytes);

      expect(parsedMessage.header.bodyLength, equals(jsonEncode(body).length));
      expect(parsedMessage.header.dataType, equals(dataType));
      expect(parsedMessage.header.queue, equals(queue));
      expect(parsedMessage.body, equals(body));
    });

    test('Message fromHeader', () {
      final int dataType = 1;
      final int queue = 42;
      final Map<String, dynamic> body = {'key': 'value'};
      final Message originalMessage = Message(dataType, queue, body);

      final Message newMessage = Message.fromHeader(
        originalMessage.header,
        originalMessage.rawBody,
      );

      expect(newMessage.header.bodyLength, equals(jsonEncode(body).length));
      expect(newMessage.header.dataType, equals(dataType));
      expect(newMessage.header.queue, equals(queue));
      expect(newMessage.body, equals(body));
    });

    test('Message toBytes', () {
      final int dataType = 1;
      final int queue = 42;
      final Map<String, dynamic> body = {'key': 'value'};
      final Message message = Message(dataType, queue, body);

      final Uint8List expectedBytes = Uint8List.fromList([
        ...Header(message.rawBody.length, dataType, queue).toBytes(),
        ...message.rawBody,
      ]);

      final Uint8List resultBytes = message.toBytes();

      expect(resultBytes, equals(expectedBytes));
    });

    test('Message queue validation', () {
      expect(
        () => Message(1, 256, {}),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Message(1, 0, {}),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
