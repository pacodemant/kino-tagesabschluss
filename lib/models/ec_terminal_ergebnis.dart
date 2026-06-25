class EcTerminalErgebnis {
  const EcTerminalErgebnis({
    required this.tid,
    required this.girocard,
    required this.lastschrift,
    required this.mastercard,
    required this.visa,
    required this.maestro,
    required this.vpay,
  });

  final String tid;
  final int girocard;
  final int lastschrift;
  final int mastercard;
  final int visa;
  final int maestro;
  final int vpay;
}
