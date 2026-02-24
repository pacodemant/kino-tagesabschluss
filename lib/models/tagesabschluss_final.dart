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

    return TagesabschlussFinal(
      kinoId: (json['kinoId'] as String?) ?? '',
      kinoName: (json['kinoName'] as String?) ?? '',
      datum: DateTime.tryParse(datumIso) ?? DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: DateTime.tryParse(createdAtIso) ?? DateTime.fromMillisecondsSinceEpoch(0),
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
    );
  }
}
