/// Ein Kartenterminal eines Standorts, pro Gerät in den Einstellungen
/// konfiguriert (Run 488, ersetzt config/terminal_ids.json — Yannik:
/// keine TIDs im Code).
class TerminalEintrag {
  const TerminalEintrag({
    required this.tid,
    this.nummer = '',
    this.kinokasse = false,
  });

  final String tid;

  /// Einstellige Nummer, mit der das Gerät beschriftet ist, damit MA nicht
  /// die ganze TID vergleichen müssen. Leer = keine Nummer.
  final String nummer;

  /// Gerät hängt direkt an der Kinokasse ("KK connected"): dessen
  /// Kartenumsatz kommt im Übertrag zum Kino SOLL (Run 486).
  final bool kinokasse;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tid': tid,
    if (nummer.isNotEmpty) 'nummer': nummer,
    if (kinokasse) 'kinokasse': true,
  };

  static TerminalEintrag fromJson(Map<String, dynamic> json) {
    return TerminalEintrag(
      tid: (json['tid'] as String?) ?? '',
      nummer: (json['nummer'] as String?) ?? '',
      kinokasse: (json['kinokasse'] as bool?) ?? false,
    );
  }
}
