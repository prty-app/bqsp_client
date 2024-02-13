# BQSP Client

![Code license (MIT)](https://img.shields.io/github/license/prty-app/bqsp_client)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/prty-app/bqsp_client)
![GitHub issues](https://img.shields.io/github/issues/prty-app/bqsp_client)

Dart client for the BQSP protocol.

## Installation

To use BQSP Client in your Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  bqsp_client: ^0.3.2
```

Then, run: 

```
flutter pub get
```

## Usage

1. Create a BqspClient instance with the server host and port
```dart
final client = BqspClient(serverHost, serverPort);
```

2. Connect to the server
```dart
await client.connect();
```

3. Send a request with a type and a body
```dart
final response = await client.send(4, 'Test message');
```

4. Close connection
```dart
await client.close();
```

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please [open an issue](https://github.com/prty-app/bqsp_client/issues) or [submit a pull request](https://github.com/prty-app/bqsp_client/pulls) on the [GitHub repository](https://github.com/prty-app/bqsp_client).

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.