import 'package:bqsp_client/bqsp_client.dart';

const serverHost = '127.0.0.1';
const serverPort = 1234;

void main() async {
  final client = BqspClient(serverHost, serverPort);
  await client.connect();

  final response = await client.send(4, 'Test message');
  print('Received response: ${response?.body}');

  await client.close();
}
