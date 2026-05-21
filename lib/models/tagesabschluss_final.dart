class TagesabschlussFinal {
  const TagesabschlussFinal({
    required this.kinoId,
    required this.kinoName,
    required this.datum,
    required this.createdAt,
    required this.scheineCent,
    required this.loseMuenzenCent,
    required this.rollenCent,
    required this.umschlaegeCent,
    required this.kassenbestandGesamtCent,
    required this.wechselgeldSollwertCent,
    required this.barBestandAbzglWechselgeldCent,
    required this.kinoSollCent,
    required this.bistroSollCent,
    required this.ausgabenCent,
    required this.ecBelegeCent,
    required this.ecUmsatzGesamtCent,
    required this.gesamtSollCent,
    required this.gesamtIstCent,
    required this.differenzGesamtCent,
    required this.differenzAnfangsbestandCent,
    // Rohdaten – seit Run 168, für ältere gespeicherte Einträge null
    this.scheineStueckzahlen,
    this.rollenStueckzahlen,
    this.silberMuenzenCent,
    this.kupferMuenzenCent,
    this.umschlagBetraegeCent,
    this.ausgabenBetraegeCent,
    this.ausgabenLabels,
  });

  final String kinoId;
  final String kinoName;
  final DateTime datum;
  final DateTime createdAt;

  final int scheineCent;
  final int loseMuenzenCent;
  final int rollenCent;
  final int umschlaegeCent;
  final int kassenbestandGesamtCent;
  final int wechselgeldSollwertCent;
  final int barBestandAbzglWechselgeldCent;

  final int kinoSollCent;
  final int bistroSollCent;
  final int ausgabenCent;
  final List<int> ecBelegeCent;
  final int ecUmsatzGesamtCent;
  final int gesamtSollCent;
  final int gesamtIstCent;
  final int differenzGesamtCent;
  final int differenzAnfangsbestandCent;

  // Rohdaten Geldzählung – Schlüssel entsprechen den IDs aus StueckelungKonfiguration
  // (z. B. note_100, note_50 für Scheine; roll_2e, roll_1e für Rollen)
  final Map<String, int>? scheineStueckzahlen;
  final Map<String, int>? rollenStueckzahlen;
  final int? silberMuenzenCent;
  final int? kupferMuenzenCent;
  final List<int>? umschlagBetraegeCent;

  // Rohdaten Einnahmen
  final List<int>? ausgabenBetraegeCent;
  final List<String>? ausgabenLabels;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'kinoId': kinoId,
      'kinoName': kinoName,
      'datumIso': datum.toIso8601String(),
      'createdAtIso': createdAt.toIso8601String(),
      'scheineCent': scheineCent,
      'loseMuenzenCent': loseMuenzenCent,
      'rollenCent': rollenCent,
      'umschlaegeCent': umschlaegeCent,
      'kassenbestandGesamtCent': kassenbestandGesamtCent,
      'wechselgeldSollwertCent': wechselgeldSollwertCent,
      'barBestandAbzglWechselgeldCent': barBestandAbzglWechselgeldCent,
      'kinoSollCent': kinoSollCent,
      'bistroSollCent': bistroSollCent,
      'ausgabenCent': ausgabenCent,
      'ecBelegeCent': ecBelegeCent,
      'ecUmsatzGesamtCent': ecUmsatzGesamtCent,
      'gesamtSollCent': gesamtSollCent,
      'gesamtIstCent': gesamtIstCent,
      'differenzGesamtCent': differenzGesamtCent,
      'differenzAnfangsbestandCent': differenzAnfangsbestandCent,
      if (scheineStueckzahlen != null)
        'scheineStueckzahlen': scheineStueckzahlen,
      if (rollenStueckzahlen != null)
        'rollenStueckzahlen': rollenStueckzahlen,
      if (silberMuenzenCent != null) 'silberMuenzenCent': silberMuenzenCent,
      if (kupferMuenzenCent != null) 'kupferMuenzenCent': kupferMuenzenCent,
      if (umschlagBetraegeCent != null)
        'umschlagBetraegeCent': umschlagBetraegeCent,
      if (ausgabenBetraegeCent != null)
        'ausgabenBetraegeCent': ausgabenBetraegeCent,
      if (ausgabenLabels != null) 'ausgabenLabels': ausgabenLabels,
    };
  }

  static TagesabschlussFinal fromJson(Map<String, dynamic> json) {
    final List<int> ecBelege = <int>[];
    final Object? ecBelegeRoh = json['ecBelegeCent'];
    if (ecBelegeRoh is List<dynamic>) {
      for (final dynamic wert in ecBelegeRoh) {
        ecBelege.add((wert as num?)?.toInt() ?? 0);
      }
    }

    final String datumIso = (json['datumIso'] as String?) ?? '';
    final String createdAtIso = (json['createdAtIso'] as String?) ?? '';

    Map<String, int>? scheineStueckzahlen;
    final Object? scheineRoh = json['scheineStueckzahlen'];
    if (scheineRoh is Map) {
      scheineStueckzahlen = scheineRoh.map(
        (dynamic k, dynamic v) =>
            MapEntry<String, int>(k.toString(), (v as num?)?.toInt() ?? 0),
      );
    }

    Map<String, int>? rollenStueckzahlen;
    final Object? rollenRoh = json['rollenStueckzahlen'];
    if (rollenRoh is Map) {
      rollenStueckzahlen = rollenRoh.map(
        (dynamic k, dynamic v) =>
            MapEntry<String, int>(k.toString(), (v as num?)?.toInt() ?? 0),
      );
    }

    List<int>? umschlagBetraegeCent;
    final Object? umschlagRoh = json['umschlagBetraegeCent'];
    if (umschlagRoh is List) {
      umschlagBetraegeCent =
          umschlagRoh.map((dynamic e) => (e as num?)?.toInt() ?? 0).toList();
    }

    List<int>? ausgabenBetraegeCent;
    final Object? ausgabenRoh = json['ausgabenBetraegeCent'];
    if (ausgabenRoh is List) {
      ausgabenBetraegeCent =
          ausgabenRoh.map((dynamic e) => (e as num?)?.toInt() ?? 0).toList();
    }

    List<String>? ausgabenLabels;
    final Object? ausgabenLabelsRoh = json['ausgabenLabels'];
    if (ausgabenLabelsRoh is List) {
      ausgabenLabels = ausgabenLabelsRoh.whereType<String>().toList();
    }

    return TagesabschlussFinal(
      kinoId: (json['kinoId'] as String?) ?? '',
      kinoName: (json['kinoName'] as String?) ?? '',
      datum: DateTime.tryParse(datumIso) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: DateTime.tryParse(createdAtIso) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      scheineCent: (json['scheineCent'] as num?)?.toInt() ?? 0,
      loseMuenzenCent: (json['loseMuenzenCent'] as num?)?.toInt() ?? 0,
      rollenCent: (json['rollenCent'] as num?)?.toInt() ?? 0,
      umschlaegeCent: (json['umschlaegeCent'] as num?)?.toInt() ?? 0,
      kassenbestandGesamtCent:
          (json['kassenbestandGesamtCent'] as num?)?.toInt() ?? 0,
      wechselgeldSollwertCent:
          (json['wechselgeldSollwertCent'] as num?)?.toInt() ?? 0,
      barBestandAbzglWechselgeldCent:
          (json['barBestandAbzglWechselgeldCent'] as num?)?.toInt() ?? 0,
      kinoSollCent: (json['kinoSollCent'] as num?)?.toInt() ?? 0,
      bistroSollCent: (json['bistroSollCent'] as num?)?.toInt() ?? 0,
      ausgabenCent: (json['ausgabenCent'] as num?)?.toInt() ?? 0,
      ecBelegeCent: ecBelege,
      ecUmsatzGesamtCent: (json['ecUmsatzGesamtCent'] as num?)?.toInt() ?? 0,
      gesamtSollCent: (json['gesamtSollCent'] as num?)?.toInt() ?? 0,
      gesamtIstCent: (json['gesamtIstCent'] as num?)?.toInt() ?? 0,
      differenzGesamtCent: (json['differenzGesamtCent'] as num?)?.toInt() ?? 0,
      differenzAnfangsbestandCent:
          (json['differenzAnfangsbestandCent'] as num?)?.toInt() ?? 0,
      scheineStueckzahlen: scheineStueckzahlen,
      rollenStueckzahlen: rollenStueckzahlen,
      silberMuenzenCent: (json['silberMuenzenCent'] as num?)?.toInt(),
      kupferMuenzenCent: (json['kupferMuenzenCent'] as num?)?.toInt(),
      umschlagBetraegeCent: umschlagBetraegeCent,
      ausgabenBetraegeCent: ausgabenBetraegeCent,
      ausgabenLabels: ausgabenLabels,
    );
  }
}
