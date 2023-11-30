enum DataType {
  error(0),
  jsonRequest(1),
  jsonResponse(2),
  echo(4),
  ping(5),
  register(6),
  verify(7),
  login(8),
  reconnect(11),
  ok(42),
  session(43),
  verifyToken(44),
  value(47),
  unknown(65535);

  final int id;

  const DataType(this.id);

  factory DataType.fromId(int id) {
    return switch (id) {
      0 => DataType.error,
      1 => DataType.jsonRequest,
      2 => DataType.jsonResponse,
      4 => DataType.echo,
      5 => DataType.ping,
      6 => DataType.register,
      7 => DataType.verify,
      8 => DataType.login,
      11 => DataType.reconnect,
      42 => DataType.ok,
      43 => DataType.session,
      44 => DataType.verifyToken,
      47 => DataType.value,
      _ => DataType.unknown,
    };
  }
}
